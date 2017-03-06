defmodule Chat do
  use Application

  
  @doc """
  run iex -S mix to start
  
  Create a room with Chat.Supervisor.start_room("room_name_example")

  Send a message to the room using Chat.Server.add_msg("room_name_example", "message")

  You can use the Registry to find the pid of each of the rooms etc. 
  """

  def start(_type, _args) do
  	Chat.Registry.start_link
    Chat.Supervisor.start_link
  end
end
