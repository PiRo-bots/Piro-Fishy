PwmDriver = require('adafruit-i2c-pwm-driver')
#AltImu10 = requre('alt-imu10-node')

class Servo
  constructor:(pwm, channel)->
    @pwm = pwm
    @channel = channel or 0
    @min = 150 # Min pulse length out of 4096
    @max = 600 # Max pulse length out of 4096
  
  rotate:(amount)->
    console.log("rotate servo to #{amount}")
    @pwm.setPWM(@channel,0, amount)
    

class Robot
  constructor:->
    #actuators
    @pwm = new PwmDriver( 0x40, '/dev/i2c-1')
    @pwm.setPWMFreq(60) # Set frequency to 60 Hz  
  
    @leftFin = new Servo(@pwm,0)
    @rightFin = new Servo(@pwm,1)
    
    @caudalFin1 = new Servo(@pwm,2)
    @caudalFin2 = new Servo(@pwm,3)
    
    #sensors
    #@imu = new AltImu10()
  
  rotateLeftFin:(amount)->
    @leftFin.rotate( amount )
    
    

module.exports = Robot