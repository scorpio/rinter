#!/usr/bin/env ruby
require 'rinterceptor'
module RinterceptorExample
  def rinter_before(method, *args)
    p "instance before -- method: #{method}, args: #{args} in RinterceptorExample"
  end
  def rinter_after(method, result, exception, *args)
    p "instance after -- method: #{method}, result: #{result}, exception: #{exception}, args: #{args} in RinterceptorExample"
    result
  end

  module ClassMethods
    def rinter_before(method, *args)
      p "singleton before -- method: #{method}, args: #{args} in RinterceptorExample"
    end
    def rinter_after(method, result, exception, *args)
      p "singleton after -- method: #{method}, result: #{result}, exception: #{exception}, args: #{args} in RinterceptorExample"
    end
  end
  include Rinterceptor
end

module SubRinterceptorExample
  def self.rinter_before_include_class(base)
    p "before_include_class in SubRinterceptorExample"
    #set interceptor rules of instance methods, the variable can also be defined in class before include this module 
    base.instance_variable_set(:@include_i_methods, {nil => [/^i2_/, /^i3_/], :handler_it => /^i1_/})
  end
  def self.rinter_after_include_class(base)
    p "after_include_class in SubRinterceptorExample"
  end
  def rinter_handler_it_around(invocation)
    p "instance handler_it around begin -- method: #{invocation.method}, args: #{invocation.args} in SubRinterceptorExample"
    result = invocation.invoke("inter", "ddddd")
    p "instance handler_it around end -- method: #{invocation.method}, args: #{invocation.args} in SubRinterceptorExample"
    result
  end
  module ClassMethods
    def rinter_before(method, *args)
      p "singleton before -- method: #{method}, args: #{args}  in SubRinterceptorExample"
    end
  end
  include RinterceptorExample
end



if __FILE__ == $0
  
class TestRinterceptor
  def i1_test(x, y)
    p "i1_test x:#{x} y:#{y}"
  end
  def i2_test(x, y)
    p "i2_test x:#{x} y:#{y}"
  end
  def i3_test(x, y)
    p "i3_test x:#{x} y:#{y}"
  end
  def self.s_test(x, y)
    p "s_test x:#{x} y:#{y}"
  end
  #set interceptor rules of singleton methods, an alternative way is demonstrated in "self.rinter_before_include_class" of SubRinterceptorExample
  #@include_s_methods value example: 
  #String(for exactly match)
  #Regexp
  #[Regexp]
  #{} (unless key.nil? use rinter_#{key}_around to handle it, otherwise same behavior as before)
  #refor to SubRinterceptorExample
  @include_s_methods = [/^s_/] 
  include SubRinterceptorExample
end
p "--------call TestRinterceptor.new.i1_test -------------------------------------"
TestRinterceptor.new.i1_test("xxx", "yyy")
p "--------call TestRinterceptor.new.i2_test -------------------------------------"
TestRinterceptor.new.i2_test("xxx", "yyy")
p "--------call TestRinterceptor.new.i3_test -------------------------------------"
TestRinterceptor.new.i3_test("xxx", "yyy")
p "--------call TestRinterceptor.s_test -------------------------------------"
TestRinterceptor.s_test("xxx", "yyy")
end


