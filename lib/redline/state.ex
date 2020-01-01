defmodule Redline.State do
  def new, do: %{results: %{}, states: %{}}

  def reset_results(state), do: %{state | results: %{}}

  def get_results!(state, names) when is_list(names) do
    names
    |> Enum.map(fn name -> get_result!(state, name) end)
    |> List.to_tuple()
  end

  def get_result!(state, name) do
    case get_in(state.results, [name]) do
      nil -> raise %KeyError{key: name, term: state.results}
      result -> result
    end
  end

  def get_step_state(state, name, module) do
    case get_in(state.states, [name]) do
      nil -> module.new()
      step_state -> step_state
    end
  end

  def update_step(state, name, result, step_state),
    do: state |> update_results(name, result) |> update_states(name, step_state)

  def update_results(state, name, result), do: put_in(state, [:results, name], result)

  def update_states(state, name, step_state), do: put_in(state, [:states, name], step_state)
end
