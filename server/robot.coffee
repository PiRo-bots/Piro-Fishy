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
    

class Light
  constructor:(pwm, channel)->
    @pwm = pwm
    @channel = channel or 0
    @minPulse = 0 # Min pulse length out of 4096
    @maxPulse = 4095 # Max pulse length out of 4096
    @minIntensity= 0
    @maxIntensity = 512
  
  setIntensity:(intensity)->
    console.log("set light at channel #{@channel} to #{intensity}")
    clampedIntensity = Math.max(@minIntensity,Math.min(intensity,@maxIntensity))
    pulseRange = @maxPulse - @minPulse
    intensityRange = @maxIntensity - @minIntensity
    
    pulse = (clampedIntensity-@minIntensity)/intensityRange * pulseRange + @minPulse
    
    if @debug
      console.log("clamped", clampedIntensity)
      console.log("pulseRange",pulseRange,"intensityRange",intensityRange)
      console.log("pulse", pulse)
    
    @pwm.setPWM(@channel,0, pulse)

class PanTiltHead
  constructor:(pwm, channelRoll, channelPitch)->
    @pwm = pwm
    @channelRoll = channelRoll or 0
    @channelPitch = channelPitch or 0

    @minPulse = 150 # Min pulse length out of 4096
    @maxPulse = 600 # Max pulse length out of 4096
    @minAngle = -60
    @maxAngle = 60
  
  rotate:(toAngleR, toAngleP)->
    #rotate first axis
    console.log("rotate camera servo at channel #{@channelRoll} to #{toAngleR}")
    
    clampedAngleR = Math.max(@minAngle,Math.min(toAngleR,@maxAngle))
    pulseRange = @maxPulse - @minPulse
    angleRange = @maxAngle - @minAngle
    
    pulse = (clampedAngleR-@minAngle)/angleRange * pulseRange + @minPulse
    
    if @debug
      console.log("clamped", clampedAngleR)
      console.log("pulseRange",pulseRange,"angleRange",angleRange)
      console.log("pulse", pulse)
    @pwm.setPWM(@channelRoll,0, pulse)

    #rotate second axis
    console.log("rotate camera servo at channel #{@channelPitch} to #{toAngleP}")

    clampedAngleP = Math.max(@minAngle,Math.min(toAngleP,@maxAngle))
    pulseRange = @maxPulse - @minPulse
    angleRange = @maxAngle - @minAngle
    
    pulse = (clampedAngleP-@minAngle)/angleRange * pulseRange + @minPulse
    
    if @debug
      console.log("clamped", clampedAngleP)
      console.log("pulseRange",pulseRange,"angleRange",angleRange)
      console.log("pulse", pulse)
    
    @pwm.setPWM(@channelPitch,0, pulse)



class Robot
  constructor:->
    #actuators
    try
      @pwm = new PwmDriver(0x40)
      @pwm.setPWMFreq(60) # Set frequency to 60 Hz  
    catch error
    
    @leftFin = new Servo(@pwm,0)
    @rightFin = new Servo(@pwm,1)
    
    @caudalSeg1 = new Servo(@pwm,2)
    @caudalSeg2 = new Servo(@pwm,3)
    
    @headLight = new Light(@pwm,4)

    @panTiltHead = new PanTiltHead( @pwm, 5, 6 )
    
    #sensors
    #@imu = new AltImu10()
    @init()
  
  init:->
    #set to neutral
    @leftFin.rotate( 0 )
    @rightFin.rotate( 0 )
    @headLight.setIntensity( 0 )
    @panTiltHead.rotate(0,0)
  
  rotateLeftFin:(amount)->
    @leftFin.rotate( amount )
  
  rotateRightFin:(amount)->
    @rightFin.rotate( amount )
    
  rotateCaudalSeg1:( toAngle )->
    @caudalSeg1.rotate( toAngle )
  
  rotateCaudalSeg2:( toAngle )->
    @caudalSeg2.rotate( toAngle )

  rotateHead:( angleR, angleP)->
    @panTiltHead.rotate(angleR,angleP)
    
  setLight:(intensity)->
    @headLight.setIntensity( intensity )
  
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
