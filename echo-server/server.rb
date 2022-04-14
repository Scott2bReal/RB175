require 'socket'

def roll_dice(params)
  rand(params["sides"].to_i) + 1
end

def parse_query(query)
  components = (query || "").split("&")

  components.each_with_object({}) do |component, hash|
    parameter, value = component.split("=")
    hash[parameter] = value
  end
end

def parse_request_line(request_line)
  components_array = request_line.split # => [GET, /?rolls=2&sides=6, HTTP/1.1]

  method, http_version = components_array[0], components_array[2]
  path, query = components_array[1].split("?")
  query = parse_query(query)

  components = {
    "method" => method,
    "path" => path,
    "query" => query,
    "http_version" => http_version
  }

  components
end

server = TCPServer.new('localhost', 3003)

loop do
  client = server.accept

  request_line = client.gets
  next if !request_line || request_line =~ /favicon/
  puts request_line

  components = parse_request_line(request_line)

  client.puts "HTTP/1.0 200 OK"
  client.puts "Content-Type: text/html"
  client.puts
  client.puts "<html>"
  client.puts "<body>"
  client.puts "<pre>"
  client.puts components["method"]
  client.puts components["path"]
  client.puts components["query"]
  client.puts "</pre>"

  client.puts "<h1>Counter</h1>"

  number = components["query"]["number"].to_i
  client.puts "<p> The current number is #{number}.</p>"

  # client.puts "<h1>Rolls</h1>"
  # components["query"]["rolls"].to_i.times do
  #   client.puts "<p>", roll_dice(components["query"]), "</p>"
  # end

  client.puts "<a href='?number=#{number + 1}'>Plus one!</a>"
  client.puts "<a href='?number=#{number - 1}'>Minus one!</a>"

  client.puts "</body>"
  client.puts "</html>"
  client.close
end
