class TestActor < Transactor::Actor
  attr_reader :performed

  def perform
    @performed = true
  end

  def rollback
    @performed = false
  end
end

class FailingActor < Transactor::Actor
  attr_reader :rolled_back

  def perform
    raise "FAIL"
  end

  def rollback
    @rolled_back = true
  end
end
