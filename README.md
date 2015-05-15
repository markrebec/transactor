# Transactor

[![Build Status](https://travis-ci.org/markrebec/transactor.png)](https://travis-ci.org/markrebec/transactor)
[![Coverage Status](https://coveralls.io/repos/markrebec/transactor/badge.svg?1=1)](https://coveralls.io/r/markrebec/transactor)
[![Code Climate](https://codeclimate.com/github/markrebec/transactor.png)](https://codeclimate.com/github/markrebec/transactor)
[![Gem Version](https://badge.fury.io/rb/transactor.png)](http://badge.fury.io/rb/transactor)
[![Dependency Status](https://gemnasium.com/markrebec/transactor.png)](https://gemnasium.com/markrebec/transactor)

Transactional actors for easy rollbacks

```ruby
# probably use https://github.com/collectiveidea/interactor as a base for the actors?

class CacheInRedis < Transactor::Actor
  def perform
    # put your key/value into redis

    # OR save the old value to an instance var and
    # update with the new value
  end

  def rollback
    # delete your key/value

    # OR restore the old value from an instance var
  end
end

class UpdateActiveRecord < Transactor::Actor
  def perform
    MyModel.update(my_attr: @my_attr)
  end

  def rollback
    # automatic, optional if there is extra work to do, all
    # Transactor transactions are also ActiveRecord transactions
  end
end

class SendChargeToStripe < Transactor::Actor
  def perform
    # send a charge to Stripe
  end

  def rollback
    # send a cancellation for the charge
  end
end

class EmailCustomer < Transactor::Actor
  def perform
    # send an email to the customer
  end

  def rollback
    # maybe do nothing?
    # maybe send an email that there was a problem
  end
end

Transactor.transaction do
  CacheInRedis.perform(key, value)
  UpdateActiveRecord.perform(my_attr: value)
  SendChargeToStripe.perform(amount)
  EmailCustomer.perform(user, amount)
end

Transactor.transaction cache_in_redis: [key, value], update_active_record: {my_attr: value}, send_charge_to_stripe: amount, email_customer: [user, amount]

Transactor.transaction do
  Transactor.perform(*args) do |arg1,arg2|
    # do something here
  end.rollback do |result,arg1,arg2|
    # roll it back if something fails after this block
  end

  # another transactor could go here or simply anything
  # that might raise an exception
end
```
