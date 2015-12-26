import nitcorn

class HTCPCPAction
  super Action
  var brewing = false

  redef fun answer(http_request, turi) do
    var title: String
    var message: String
    var method = http_request.method
    var headers = http_request.header
    var response

    if method == "POST" or method == "BREW" then
      title = "BREWING"
      message = "Brewing a new pot of coffee"
      brewing = true
      response = new HttpResponse(200)
    else if method == "WHEN" and brewing then
      title = "STOP ADDING MILK"
      message = "Stopped adding milk, your coffee is ready!"
      brewing = false
      response = new HttpResponse(200)
    else
      title = "ERROR"
      message = "Error Brewing Coffe"
      brewing = false
      response = new HttpResponse(500)
    end

    response.body = """
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>{{{title}}}</title>
      </head>
      <body>
        <h1>{{{title}}}</h1>
        <p>{{{message}}}<p>
      </body>
      </html>
    """

    return response
  end
end


class HTCPCServer
  var port: Int
  var host: String

  fun run do
    var vh = new VirtualHost("{host}:{port}")
    vh.routes.add new Route("/", new HTCPCPAction)
    var factory = new HttpFactory.and_libevent
    factory.config.virtual_hosts.add vh
    print "Nit4Coffee is now running at port: {port}"
    factory.run
  end
end

var server = new HTCPCServer(8080,"localhost")

server.run