require 'ruby2d'
require 'csv'
require 'lurn'

# CONSTANTS
BACKGROUND_COLOR = 'black'
FOREGROUND_COLOR = 'white'
WINDOW_WIDTH = 640
WINDOW_HEIGHT = 480
SPEED_MULTIPLIER = 4 # TODO
X_SPEED = 3 * SPEED_MULTIPLIER
Y_SPEED = 2 * SPEED_MULTIPLIER

# SETTINGS
set title: "Pong", background: BACKGROUND_COLOR, 
    width: WINDOW_WIDTH, height: WINDOW_HEIGHT

# CLASSES
class Border
  BORDER_SIZE = 10

  def initialize
    # Top
    Rectangle.new(
      x: 0, y: 0,
      width: WINDOW_WIDTH, height: BORDER_SIZE,
      color: FOREGROUND_COLOR
    )
  
    # Bottom
    Rectangle.new(
      x: 0, y: WINDOW_HEIGHT - BORDER_SIZE,
      width: WINDOW_WIDTH, height: BORDER_SIZE,
      color: FOREGROUND_COLOR
    )
  end
end

class Paddle
  PADDLE_WIDTH = 15
  PADDLE_HEIGHT = 50

  def initialize(side)
    if side == :right
      x = (WINDOW_WIDTH - PADDLE_WIDTH)
    else
      x = 0
    end
    @shape = Rectangle.new(
      x: x, y: ((WINDOW_HEIGHT / 2) - (PADDLE_HEIGHT / 2)),
      width: PADDLE_WIDTH, height: PADDLE_HEIGHT,
      color: FOREGROUND_COLOR
    )
  end

  def up
    if not @shape.contains? (WINDOW_WIDTH - PADDLE_WIDTH), Border::BORDER_SIZE
      @shape.y = @shape.y - Y_SPEED - SPEED_MULTIPLIER
    end
  end

  def down
    if not @shape.contains? (WINDOW_WIDTH - PADDLE_WIDTH), (WINDOW_HEIGHT - Border::BORDER_SIZE)
      @shape.y = @shape.y + Y_SPEED + SPEED_MULTIPLIER
    end
  end

  def x
    @shape.x
  end

  def y
    @shape.y
  end
end

class Ball
  BALL_RADIUS = 5

  def initialize
    @shape = Circle.new(
      x: (WINDOW_HEIGHT / 2), y: (WINDOW_WIDTH / 2),
      radius: BALL_RADIUS,
      color: FOREGROUND_COLOR
    )
    @direction = {x: 1, y: -1}
  end

  def move(paddle1, paddle2)
    if @shape.contains? @shape.x, Border::BORDER_SIZE
      deflect(:up)
    end
    if @shape.contains? @shape.x, (WINDOW_HEIGHT - Border::BORDER_SIZE)
      deflect(:down)
    end
    if @shape.x <= (paddle1.x + Paddle::PADDLE_WIDTH) and @shape.y >= paddle1.y and @shape.y <= (paddle1.y + Paddle::PADDLE_HEIGHT)
      deflect(:left)
    end
    if @shape.x >= paddle2.x and @shape.y >= paddle2.y and @shape.y <= (paddle2.y + Paddle::PADDLE_HEIGHT)
      deflect(:right)
    end

    @shape.x = @shape.x + (@direction[:x] * X_SPEED)
    @shape.y = @shape.y + (@direction[:y] * Y_SPEED)
  end

  def deflect(direction)
    case direction
    when :up, :down
      @direction = {x: @direction[:x], y: -@direction[:y]}
    when :left, :right
      @direction = {x: -@direction[:x], y: @direction[:y]}
    end
  end

  def x
    @shape.x
  end

  def y
    @shape.y
  end

  def direction
    @direction
  end
end

# TRAINING AI
data = CSV.read("game.csv")
data.shift

data = data.map { |row| row.map { |x| x.to_i }}

predictors = data.map { |row| row[0..3] }
target_var = data.map { |row| row[4]}

model = Lurn::Neighbors::KNNRegression.new(3)
model.fit(predictors, target_var)

# MAIN
border = Border.new

paddle1 = Paddle.new(:left)
paddle2 = Paddle.new(:right)

ball = Ball.new

on :key_held do |event|
  case event.key
  when 'up'
    paddle1.up
  when 'down'
    paddle1.down
  end
end

update do
  ball.move(paddle1, paddle2)

  predicted_y = model.predict([ball.x, ball.y, ball.direction[:x], ball.direction[:y]])

  if predicted_y > paddle2.y
    paddle2.down
  else
    paddle2.up
  end

  if ball.x <= 0 or ball.x >= WINDOW_WIDTH
    close
  end
end

show

