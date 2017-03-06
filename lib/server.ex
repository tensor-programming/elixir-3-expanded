defmodule Chat.Server do
	use GenServer 

	#client side
	def start_link(name) do
		GenServer.start_link(__MODULE__, [], name: via_tuple(name))
	end

	def get_msgs(room_name) do
		GenServer.call(via_tuple(room_name), :get_msgs)
	end

	def add_msg(room_name, msg) do
		GenServer.cast(via_tuple(room_name), {:add_msg, msg})
	end

	defp via_tuple(room_name) do
		#format of tuple, {:via, module, term}
		{:via, Chat.Registry, {:chat_room, room_name}}
	end
	#server side / callback functions
	
	def init(msgs) do
		{:ok, msgs}
	end

	def handle_call(:get_msgs, _form, msgs) do
		{:reply, msgs, msgs}
	end

	def handle_cast({:add_msg, msg}, msgs) do
		{:noreply, [msg | msgs]}
	end

end


