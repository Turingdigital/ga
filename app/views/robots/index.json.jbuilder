json.array!(@robots) do |robot|
  json.extract! robot, :id, :count, :target, :title, :cs, :cm, :cn, :ul, :geoid, :sr, :vp, :ua
  json.url robot_url(robot, format: :json)
end
