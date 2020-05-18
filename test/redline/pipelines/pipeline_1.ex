defmodule Test.Redline.Pipelines.Pipeline1 do
  alias Test.Redline.Steps

  use Redline, name: :pipeline

  step Steps.Step1

  step Steps.Step1, name: :step_1_b, input: :step_1

  step [Steps.Step2, Steps.Step3]

  step Steps.Step4
end
