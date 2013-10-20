var socket = io.connect();

function sendMessage(command, value) {
	
	console.log("Message",value)
	
	socket.emit('message', {command:command, value:value});
}

