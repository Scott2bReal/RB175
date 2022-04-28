ENV["RACK_ENV"] = 'test'

require 'fileutils'
require 'minitest/autorun'
require 'rack/test'
require 'minitest/reporters'
Minitest::Reporters.use!

require_relative '../cms'

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  MUST_SIGN_IN_ERROR_MESSAGE = "You must be signed in to do that"

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def create_document(name, content = '')
    File.open(File.join(data_path, name), 'w') do |file|
      file.write(content)
    end
  end

  def session
    last_request.env["rack.session"]
  end

  def admin_session
    {
      "rack.session" => {
        username: 'admin',
        password: 'secret'
      }
    }
  end

  def delete_test_sesh
    {
      "rack.session" => {
        username: 'new_user',
        password: 'password'
      }
    }
  end

  def test_index
    create_document "about.md", "# Headline"
    create_document "changes.txt"

    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response["Content-Type"]
    assert_includes last_response.body, ("about.md")
    assert_includes last_response.body, ("changes.txt")
    assert_includes last_response.body, ("edit")
  end

  def test_viewing_text_document
    create_document('history.txt', 'Matsumoto')

    get "/history.txt"

    assert_equal 200, last_response.status
    assert_equal 'text/plain', last_response["Content-Type"]
    assert_includes last_response.body, "Matsumoto"
  end

  def test_viewing_nonexistant_document
    get "/notafile.ext"

    assert_equal 302, last_response.status
    assert_equal "notafile.ext does not exist", session[:error]

    get '/'

    assert_nil session[:error]
  end

  def test_viewing_markdown_document
    create_document("/about.md", "# Headline!")

    get '/about.md'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response["Content-Type"]
    assert_includes last_response.body, "<h1>"
  end

  def test_view_edit_page_while_logged_in
    create_document('changes.txt')

    get '/changes.txt/edit', {}, admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response["Content-Type"]
    assert_includes last_response.body, "<form"
  end

  def test_view_edit_page_while_not_logged_in
    create_document('changes.txt')

    get '/changes.txt/edit'

    assert_equal 302, last_response.status
    assert_equal MUST_SIGN_IN_ERROR_MESSAGE, session[:error]

    get '/'

    assert_nil session[:error]
  end

  def test_submitting_edit_file_redirects_and_shows_flash_message
    post '/changes.txt', {}, admin_session

    assert_equal 302, last_response.status
    assert_equal "changes.txt has been edited.", session[:success]

    get '/'

    assert_nil session[:success]
  end

  def test_editing_file_changes_contents_while_signed_in
    create_document("changes.txt")
    post '/changes.txt', { edit: "This is the new text!" }, admin_session

    assert_equal 302, last_response.status

    get '/changes.txt'

    assert_equal 200, last_response.status
    assert_includes last_response.body, "This is the new text!"
  end

  def test_submitting_edit_while_not_logged_in_fails
    create_document("changes.txt")
    post '/changes.txt'

    assert_equal 302, last_response.status
    assert_equal MUST_SIGN_IN_ERROR_MESSAGE, session[:error]

    get last_response["Location"]

    assert_nil session[:error]
  end

  def test_view_create_document_page_while_signed_in
    get '/new', {}, admin_session

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response["Content-Type"]
    assert_includes last_response.body, '<input'
  end

  def test_cannot_view_create_document_page_while_signed_in
    get '/new'

    assert_equal 302, last_response.status
    assert_equal MUST_SIGN_IN_ERROR_MESSAGE, session[:error]

    get last_response["Location"]

    assert_nil session[:error]
  end

  def test_create_document_creates_new_document
    post '/create', { filename: "new_file.txt" }, admin_session

    assert_equal 302, last_response.status

    get last_response["Location"]

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response["Content-Type"]
    assert_includes last_response.body, "new_file.txt"
  end

  def test_signed_out_users_cannot_create_document
    post '/create', filename: 'wont_work'

    assert_equal 302, last_response.status
    assert_equal MUST_SIGN_IN_ERROR_MESSAGE, session[:error]

    get '/'

    assert_nil session[:error]
  end

  def test_creating_new_document_displays_flash_message
    post '/create', { filename: 'new_file.txt' }, admin_session

    assert_equal 'new_file.txt was created.', session[:success]

    get '/'

    assert_nil session[:success]
  end

  def test_does_not_accept_blank_name_for_new_doc
    post '/create', { filename: "" }, admin_session

    assert_equal 422, last_response.status

    assert_includes last_response.body, "A name is required."

    get '/new'

    refute_includes last_response.body, "A name is required."
  end

  def test_does_not_accept_name_already_in_use
    create_document('new.txt')
    post '/create', { filename: "new.txt" }, admin_session

    assert_equal 422, last_response.status

    assert_equal 'text/html;charset=utf-8', last_response["Content-Type"]
    assert_includes last_response.body, "already in use"

    get '/new'

    refute_includes last_response.body, "already in use"
  end

  def test_does_not_allow_file_without_valid_extension
    post '/create', { filename: "wont_work" }, admin_session

    assert_equal 422, last_response.status

    assert_equal 'text/html;charset=utf-8', last_response["Content-Type"]
    assert_includes last_response.body, "valid extension"

    get '/new'

    refute_includes last_response.body, "valid extension"
  end

  def test_deleting_document_works_while_signed_in
    create_document("new.txt")

    get '/', {}, admin_session

    assert_includes last_response.body, ">new.txt"

    post '/new.txt/delete'

    get last_response["Location"]

    refute_includes last_response.body, ">new.txt"
  end

  def test_successfully_deleting_document_shows_flash_message
    create_document('new.txt')

    post '/new.txt/delete', {}, admin_session

    assert_equal 'new.txt was successfully deleted.', session[:success]

    get '/'

    assert_nil session[:success]
  end

  def test_signed_out_users_cannot_delete_document
    create_document('new.txt')

    post '/new.txt/delete'

    assert_equal 302, last_response.status
    assert_equal MUST_SIGN_IN_ERROR_MESSAGE, session[:error]

    get last_response['Location']

    assert_nil session[:error]
  end

  def test_signed_out_users_can_sign_in
    get '/'

    assert_includes last_response.body, 'Sign in'
    assert_nil session[:username]

    post '/users/signin', username: 'admin', password: 'secret'

    assert_equal "admin", session[:username]
  end

  def test_signing_in_displays_flash_message
    post '/users/signin', username: 'admin', password: 'secret'

    assert_equal 'Welcome!', session[:success]

    get '/'

    assert_nil session[:sucess]
  end

  def test_signed_in_users_can_sign_out
    get '/', {}, admin_session

    assert_equal 'admin', session[:username]

    post '/users/signout'

    assert_nil session[:username]
  end

  def test_sign_in_with_bad_credentials_fails
    post '/users/signin', username: 'not', password: 'right'

    assert_equal 422, last_response.status
    assert_includes last_response.body, "Invalid Credentials"
  end

  def test_cannot_create_username_too_long
    post '/users/signup/create', {
      new_username: 'twelve characters',
      new_password: '1',
      verify_password: '1'
    }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "too long"
  end

  def test_cannot_create_username_that_already_exists
    post '/users/signup/create', {
      new_username: 'admin',
      new_password: 'secret',
      verify_password: 'secret'
    }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "already exists"
  end

  def test_new_account_passwords_must_match
    post '/users/signup/create', {
      new_username: 'test',
      new_password: 'password',
      verify_password: 'different'
    }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "must match"
  end

  def test_users_can_create_and_delete_accounts
    post '/users/signup/create', {
      new_username: 'new_user',
      new_password: 'password',
      verify_password: 'password'
    }

    assert_equal "Account 'new_user' created", session[:success]

    post '/users/new_user/delete', { password: 'password' }, delete_test_sesh

    get last_response["Location"]

    assert_includes last_response.body, "was deleted"
  end

  def test_doucments_can_be_copied
    create_document('new.txt')

    post '/new.txt/duplicate', {}, admin_session

    assert_equal 302, last_response.status
    assert_equal "new.txt was copied to copy_of_new.txt", session[:success]

    get last_response["Location"]

    assert_includes last_response.body, "copy_of"
  end

  def test_must_be_signed_in_to_duplicate_document
    create_document('new.txt')

    post '/new.txt/duplicate'

    assert_equal 302, last_response.status
    assert_equal "You must be signed in to do that", session[:error]
  end
end
