PwmDriver = require('adafruit-i2c-pwm-driver')
#AltImu10 = requre('alt-imu10-node')

class Servo
  constructor:(pwm, channel)->
    @pwm = pwm
    @channel = channel or 0
    @minPulse = 150 # Min pulse length out of 4096
    @maxPulse = 600 # Max pulse length out of 4096
    @minAngle = -60
    @maxAngle = 60
  
  rotate:(toAngle)->
    console.log("rotate servo at channel #{@channel} to #{toAngle}")
    clampedAngle = Math.max(@minAngle,Math.min(toAngle,@maxAngle))
    pulseRange = @maxPulse - @minPulse
    angleRange = @maxAngle - @minAngle
    
    pulse = (clampedAngle-@minAngle)/angleRange * pulseRange + @minPulse
    
    if @debug
      console.log("clamped", clampedAngle)
      console.log("pulseRange",pulseRange,"angleRange",angleRange)
      console.log("pulse", pulse)
    
    @pwm.setPWM(@channel,0, pulse)
    

class Robot
  constructor:->
    #actuators
    @pwm = new PwmDriver(0x40)
    @pwm.setPWMFreq(60) # Set frequency to 60 Hz  
  
    @leftFin = new Servo(@pwm,0)
    @rightFin = new Servo(@pwm,1)
    
    @caudalSeg1 = new Servo(@pwm,2)
    @caudalSeg2 = new Servo(@pwm,3)
    
    #sensors
    #@imu = new AltImu10()
    @init()
  
  init:->
    #set to neutral
    @leftFin.rotate( 0 )
    @rightFin.rotate( 0 )
  
  rotateLeftFin:(amount)->
    @leftFin.rotate( amount )
  
  rotateRightFin:(amount)->
    @rightFin.rotate( amount )
    
  rotateCaudalSeg1:( toAngle )->
    @caudalSeg1.rotate( toAngle )
  
  rotateCaudalSeg2:( toAngle )->
    @caudalSeg2.rotate( toAngle )
  
  #'meta' controls
  swim:(amount)->
  
  turn:(amount)->
    @leftFin.rotate( amount )
    #no need to send negative amount to opposite side, side servos are inverted already
    @rightFin.rotate( amount )

  dive:(angle)->
    console.log "diving at angle: #{angle}"
    #we need same rotation from all servos :send negative amount to opposite sides
    @leftFin.rotate( angle )
    @rightFin.rotate( -angle )
    

module.exports = Robot