defmodule Chat.Registry do
	use GenServer

	#client functions
	def start_link do
		GenServer.start_link(__MODULE__, nil, name: :registry)
	end

	def whereis_name(room_name) do
		GenServer.call(:registry, {:whereis_name, room_name})
	end

	def register_name(room_name, pid) do
		GenServer.call(:registry, {:register_name, room_name, pid})
	end

	def unregister_name(room_name) do
		GenServer.cast(:registry, {:unregister_name, room_name})
	end

	def send(room_name, msg) do
	# this function is used to account for unregistered rooms	
		case whereis_name(room_name) do
			:undefined -> {:badarg, {room_name, msg}}

			pid ->
				Kernel.send(pid, msg)
				pid
		end	
	end

	#Server/CallBack Functions
	
	def init(_) do
		#creating a map to store our processes in
		{:ok, Map.new}
	end

	def handle_call({:whereis_name, room_name}, _from, state) do
		{:reply, Map.get(state, room_name, :undefined), state}
	end

	def handle_call({:register_name, room_name, pid}, _from, state) do
		#check if process is already in map or not. 
		case Map.get(state, room_name) do
      		nil ->
      			# When a new process is registered, we start monitoring it.
      			Process.monitor(pid)
        		{:reply, :yes, Map.put(state, room_name, pid)}
     		 _ ->
        		{:reply, :no, state}
  		end
	end

	def handle_info({:DOWN, _, :process, pid, _}, state ) do
		#:DOWN process is dead and we use this function to remove its pid from our registry.
		{:noreply, remove_pid(state, pid)}
	end

	def remove_pid(state, dead_pid) do
		remove = fn {_key, pid} -> pid  != dead_pid end
		Enum.filter(state, remove) |> Enum.into(%{})
	end

	def handle_cast({:unregister_name, room_name}, state) do
		#allows us to remove the process from the map if we want to. 
		{:noreply, Map.delete(state, room_name)}
	end
end