--wifi setting
wifi.setmode(wifi.SOFTAP)
cfg={}
cfg.ssid="ESP-AP"
cfg.pwd="12345678"
wifi.ap.config(cfg)
cfg = {ip="192.168.1.1", netmask="255.255.255.0", gateway="192.168.1.1"}
wifi.ap.setip(cfg)

relay_pin = 6
gpio.mode(relay_pin, gpio.OUTPUT)
gpio.write(relay_pin, gpio.HIGH)


srv=net.createServer(net.TCP, 10)
srv:listen(80,function(conn)
conn:on("receive", function(client,request)
	local buf = ""
	local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
	if(method == nil)then 
		_, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP"); 
	end
	local _GET = {}
	if (vars ~= nil)then 
		for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do 
			_GET[k] = v 
		end 
	end
	
	headers = "HTTP/1.1 200 OK\r\nServer: nodemcu-httpserver\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n";
	buf = buf..'<!DOCTYPE html><html lang="en"><head>'
	buf = buf.."<h1> Hello, Welcome to Smart Lamp Holder Server</h1><p>&nbsp;</p>";
	
	if(_GET.pin == "ON")then
		  gpio.write(relay_pin, gpio.LOW);
    elseif(_GET.pin == "OFF")then
          gpio.write(relay_pin, gpio.HIGH);
    end
	
	
	buf = buf.."<p>&nbsp;</p><p><a href=\"?pin=ON\"><button>ON</button></a>&nbsp;</p>";
	buf = buf.."<p><a href=\"?pin=OFF\"><button>OFF</button></a>&nbsp;</p>";
	buf = buf..'</head></html>'
	
	client:send(headers .. buf);	
	client:close();
end)
end)


