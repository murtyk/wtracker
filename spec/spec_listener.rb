class SpecListener
  def start(notification)
    puts "**Running before the entire suite**"
  end

  def example_started(notification)
    puts "**Running before each example**"
  end

  # for profiling specs
  def example_passed(n)
    # puts n.example.full_description + ":   " + n.example.execution_result.run_time.to_s
  end

  def example_failed(notification)
    puts "**This example failed :(**"
  end
end
