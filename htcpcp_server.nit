import nitcorn

class HTCPCPAction
  super Action
  var brewing = false

  redef fun answer(http_request, turi) do
    var message: String
    var method = http_request.method
    var headers = http_request.header
    var response

    if method == "POST" or method == "BREW" then
      if brewing then
        message = "Pot Busy"
        response = new HttpResponse(400)
      else
        message = "Brewing a new pot of coffee\n"
        brewing = true
        response = new HttpResponse(200)
      end
    else if method == "WHEN" and brewing then
      message = "Stopped adding milk, your coffee is ready!\n"
      brewing = false
      response = new HttpResponse(200)
    else if method == "PROPFIND" then
      if brewing then
        message = "The pot is busy\n"
      else
        message = "The pot is ready to brew more coffee\n"
      end
      response = new HttpResponse(200)
    else
      message = "Uknown method: {method}"
      brewing = false
      response = new HttpResponse(405)
    end

    response.header["Content-Type"] = "text"
    response.body = message

    return response
  end
end


class HTCPCServer
  var port: Int

  fun run do
    var vh = new VirtualHost("localhost:{port}")
    vh.routes.add new Route("/", new HTCPCPAction)
    var factory = new HttpFactory.and_libevent
    factory.config.virtual_hosts.add vh
    print "Nit4Coffee is now running at port: {port}"
    factory.run
  end
end

var server = new HTCPCServer(8080)

server.run