Engine = Matter.Engine
World = Matter.World
Bodies = Matter.Bodies
Events = Matter.Events
Body = Matter.Body

Math.clamp = (a,b,c) -> Math.max(b,Math.min(c,a))

class PIDController
  constructor: (@k_p = 0.0, @k_i=0.0, @k_d=0.0, @sampleTime=20) ->
      @error = 0
      @lastError = 0
      @sumError = 0
      @target = 0
      @gettter = -> 0
      @setter = (val)-> 0
      @k_motor = .1

  step: () ->
    @lastError = @error
    @error = @target - @getter()
    @sumError += @error

    @out = @k_motor * Math.clamp(@k_p*@error + @k_i*@sumError + @k_d*@lastError, -1, 1)
    @setter(@out)
  setTarget: (@target) ->
    @error = 0
    @lastError = 0
    @sumError = 0
  setK_p: (_) -> @k_p = _
  setK_i: (_) -> @k_i = _*(@sampleTime/1000)
  setK_d: (_) -> @k_d = _/(@sampleTime/1000)



window.PID = PID = new PIDController(.001, .0, .001)
PID.setTarget(300)
PID.getter = => boxA.position.y
PID.setter = (val) => Body.applyForce(boxA, boxA.position, {x:0, y:val})
# create a Matter.js engine
container = document.getElementById('elevatorGraphic')
options = {
            positionIterations: 6,
            velocityIterations: 4,
            enableSleeping: false
        }
window.engine = engine = Engine.create(container, options)



# create two boxes and a ground
window.boxA = Bodies.rectangle(400, 200, 80, 80)
boxA.mass = 20
# Events.on(engine, 'tick', -> Body.applyForce(boxA, boxA.position, {x: 0, y:PID.step(boxA.position.y, engine.timing.timestamp/1000)}))
ground = Bodies.rectangle(400, 610, 810, 60, { isStatic: true })

# add all of the bodies to the world
World.add(engine.world, [boxA,  ground])

# run the engine
Engine.run(engine)

window.controlLoop = window.setInterval((-> PID.step()), PID.sampleTime)
