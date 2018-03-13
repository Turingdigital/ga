class RobotsController < ApplicationController
  before_action :set_robot, only: [:show, :edit, :update, :destroy]

  def run
    Robot.all.each{|robot|
      next if robot.count <= 0
      target = URI::encode(robot.target)
      myUri = URI.parse target
      dh = myUri.host
      dp = myUri.path
      dt = robot.title
      #  &cs=google&cm=banner
      cs = robot.cs
      cm = robot.cm
      cn = robot.cn
      tid = robot.tid

      dl = URI::encode(target)
      begin
        robot.count.times {
          cid = "#{rand(10**9)}.#{rand(10**10)}"
          url = "https://www.google-analytics.com/collect?v=1&tid=#{tid}&cid=#{cid}&t=pageview&dh=#{dh}&dp=#{dp}&dt=#{dt}&dl=#{dl}&ul=#{robot.ul}&geoid=#{robot.geoid}&sr=#{robot.sr}&vp=#{robot.vp}&ua=#{robot.ua}&sd=32-bits&fl=23.0 r0"
          url = URI::encode(url)
          Thread.new {
            sleep(1+rand()*2)
            open(url)
          }
          sleep(1+rand()*2)
        }
      end
    }

    render plain: "OK"
  end

  # GET /robots
  # GET /robots.json
  def index
    @robots = Robot.all
  end

  # GET /robots/1
  # GET /robots/1.json
  def show
  end

  # GET /robots/new
  def new
    @robot = Robot.new
  end

  # GET /robots/1/edit
  def edit
  end

  # POST /robots
  # POST /robots.json
  def create
    @robot = Robot.new(robot_params)

    respond_to do |format|
      if @robot.save
        format.html { redirect_to @robot, notice: 'Robot was successfully created.' }
        format.json { render :show, status: :created, location: @robot }
      else
        format.html { render :new }
        format.json { render json: @robot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /robots/1
  # PATCH/PUT /robots/1.json
  def update
    respond_to do |format|
      if @robot.update(robot_params)
        format.html { redirect_to @robot, notice: 'Robot was successfully updated.' }
        format.json { render :show, status: :ok, location: @robot }
      else
        format.html { render :edit }
        format.json { render json: @robot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /robots/1
  # DELETE /robots/1.json
  def destroy
    @robot.destroy
    respond_to do |format|
      format.html { redirect_to robots_url, notice: 'Robot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_robot
      @robot = Robot.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def robot_params
      params.require(:robot).permit(:count, :tid, :target, :title, :cs, :cm, :cn, :ul, :geoid, :sr, :vp, :ua)
    end
end
