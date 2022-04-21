# Practice Problems

1. Is using POST as the HTTP method for a request more secure than GET? Why or
   why not?
   
   - It is not more secure, because the parameters included are still easily
     accessible. While they are not included in the URL when using POST for a
     request, they still appear in the body of a request, and are therefore
     easily accessed and manipulated.

2. How can a web application be secured so that any data being sent between the
   client and server can not be viewed by other parties?

   - The `https` protocol can be used to make data being sent back and forth is
     secured. `https` utilizes `TLS` to encrypt data and certify the server.
