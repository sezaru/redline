defmodule Test.Redline.StateTest do
  alias Redline.State

  alias Test.Redline.Steps.Step1WithState

  use ExUnit.Case

  test "new/0 returns a new state" do
    assert State.new() == %{results: %{}, states: %{}}
  end

  test "update_results/3 updates the state result field" do
    state = State.new() |> State.update_results(:name, %{some: :data})

    assert state.results == %{name: %{some: :data}}
  end

  test "reset_results/0 returns a new state" do
    state = State.new() |> State.update_results(:name, %{some: :data})

    assert State.reset_results(state) == %{results: %{}, states: %{}}
  end

  test "get_result!/2 gets the results by names list" do
    state =
      State.new()
      |> State.update_results(:name, %{some: :data})
      |> State.update_results(:name_2, %{some: :data_2})

    assert State.get_result!(state, :name_2) == %{some: :data_2}
  end

  test "get_result!/2 with unknown name raises" do
    state = State.new() |> State.update_results(:name, %{some: :data})

    assert_raise KeyError, fn -> State.get_result!(state, :name_2) end
  end

  test "get_results!/2 gets the results by names list" do
    state =
      State.new()
      |> State.update_results(:name, %{some: :data})
      |> State.update_results(:name_2, %{some: :data_2})
      |> State.update_results(:name_3, %{some: :data_3})

    assert State.get_results!(state, [:name_3, :name_2]) == {%{some: :data_3}, %{some: :data_2}}
  end

  test "get_results!/2 with unknown names raises" do
    state = State.new() |> State.update_results(:name, %{some: :data})

    assert_raise KeyError, fn -> State.get_results!(state, [:name, :name_2]) end
  end

  test "update_states/3 updates the state states field" do
    state = State.new() |> State.update_states(:name, %{some: :state})

    assert state.states == %{name: %{some: :state}}
  end

  test "get_step_state/3 gets state by name" do
    state = State.new() |> State.update_states(:name, %{some: :state})

    assert State.get_step_state(state, :name, Step1) == %{some: :state}
  end

  test "get_step_state/3 with unknown name creates new state using module parameter" do
    state = State.new()

    assert State.get_step_state(state, :name, Step1WithState) == %{last: nil}
  end
end
