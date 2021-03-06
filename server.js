var express = require('express'); 

var app = express()
  , http = require('http')
  , server = http.createServer(app)


app.configure(function() {
   app.use(express.static(__dirname + '/public'));
});

/*
app.get('/', function(req, res){
  res.render('home.jade');
});*/


//for M-jpeg streaming
/*
fs = require('fs')

if not fs.existsSync('/tmp/stream'){
	fs.mkdirSync('/tmp/stream')
}
var spawn = require('child_process').spawn;
var exec = require('child_process').exec,

var ls    = spawn('ls', ['-lh', '/usr']);

app.get('/eyes.mjpeg', function(request, res) {
  res.writeHead(200, {
    'Content-Type': 'multipart/x-mixed-replace; boundary=myboundary',
    'Cache-Control': 'no-cache',
    'Connection': 'close',
    'Pragma': 'no-cache'
  });

  var i = 0;
  var stop = false;

  res.connection.on('close', function() { stop = true; });

  var send_next = function() {
    if (stop)
      return;
    i = (i+1) % 100;
    var filename = i + ".jpg";
    fs.readFile(__dirname + '/resources/' + filename, function (err, content) {
      res.write("--myboundary\r\n");
      res.write("Content-Type: image/jpeg\r\n");
      res.write("Content-Length: " + content.length + "\r\n");
      res.write("\r\n");
      res.write(content, 'binary');
      res.write("\r\n");
      setTimeout(send_next, 500);
    });
  };
  send_next();
});

*/

//video streaming
//raspistill -w 320 -h 240 -q 65 -o /tmp/stream/pic.jpg -tl 20 -t 9999999 -th 0:0:0 &
//LD_LIBRARY_PATH=./ ./mjpg_streamer -i "input_file.so -f /tmp/stream" -o "output_http.so -w ./www"


//for controls & sensors
require('coffee-script');
var Robot = require('./server/robot');
var body = new Robot();


var io = require('socket.io').listen(server);

io.sockets.on('connection', function (socket) {
   console.log("Connected");

	socket.on('setPseudo', function (data) {
	   socket.set('pseudo', data);
	});

	socket.on('rotation', function (message) {
	  console.log("rotation: " , message);
    body.rotateHead(message.x,message.y);
	});

	socket.on('message', function (message) {
	  console.log("we got sent this : " , message);
	  if(message.command == "left")
	  {
	  	var move = message.value;
	  	console.log("rotate left fin to",move);
	  	body.rotateLeftFin(move);
	  }
	  if(message.command == "right")
	  {
	  	var move = message.value;
	  	console.log("rotate right fin to",move);
	  	body.rotateRightFin(move);
	  }
	  
	  
	  if(message.command == "caudSeg1")
	  {
	  	var move = message.value;
	  	console.log("rotate caudal fin segment1 to",move);
	  	body.rotateCaudalSeg1(move);
	  }
	  if(message.command == "caudSeg2")
	  {
	  	var move = message.value;
	  	console.log("rotate caudal fin segment2 to",move);
	  	body.rotateCaudalSeg2(move);
	  }
	  
	   if(message.command == "headLight")
	  {
	  	var intensity = message.value;
	  	console.log("seting light intensity",intensity);
	  	body.setLight(intensity);
	  }
	  
	  
	  if(message.command == "turn")
	  {
	  	var move = message.value;
	  	console.log("turning",move);
	  	body.turn(move);
	  }
	  
	  if(message.command == "dive")
	  {
	  	var move = message.value;
	  	console.log("diving",move);
	  	body.dive(move);
	  }
	  //socket.broadcast.emit('message', data);
	});

});

/*
//server broadcast
function boom()
{
	io.sockets.emit('message', { 'message' : "fish is sinking !", pseudo : "PirO" } );
}
setInterval(boom, 5000);
*/
server.listen(3000);
console.log('Server started on port %d', server.address().port);


