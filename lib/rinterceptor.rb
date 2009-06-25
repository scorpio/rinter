=begin

For expandability, Class can not include me directly, only accept Module to include me
for example:

module MyRinterceptor
  def instance_method
  end
  module ClassMethods #don't change this name if you need singleton method
    def singleton_method
    end
  end
  include Rinterceptor #should be placed at last line of this module
end

class YourClass
  include MyRinterceptor
end


#you can refer to example_rinterceptor.rb
=end
#TODO nested interceptor
require 'rinterceptor_helper'
module Rinterceptor
  def self.included(base)
    raise 'Class can not include me directly, only accept Module to include me' if base.is_a?(Class)
    base.extend(ClassMethods)
  end

  #overridable
  def rinter_skip?
    false
  end
  
  #overridable
  def rinter_before(method, *args)
  end
  
  #overridable
  def rinter_after(method, result, e, *args)
    raise e unless e.nil?
    result
  end
  
  #overridable
  def rinter_around(invocation)
    invocation.invoke
  end
  
  module ClassMethods
    #for sub module
    def included(base)
      if base.is_a?(Class)
        rinter_before_include_class(base) #only available in last module for preparing data of Class which will include it
        base.extend(ClassMethods)
        base.ancestors[1..-1].reverse.each {|p| base.extend(p::ClassMethods) if p.respond_to?(:rinter_here?)}
        include_s_methods = base.include_s_methods || []
        include_i_methods = base.include_i_methods || []
        include_s_methods = RinterceptorHelper.process_include_methods(include_s_methods)
        include_i_methods = RinterceptorHelper.process_include_methods(include_i_methods)
        exclude_s_methods = (base.exclude_s_methods || []) + [/^rinter_/, /include_[is]_methods/, /exclude_[is]_methods/]
        exclude_i_methods = (base.exclude_i_methods || []) + [/^rinter_/, /include_[is]_methods/, /exclude_[is]_methods/]
        s_methods = (base.private_methods + base.singleton_methods).delete_if{|m| ! RinterceptorHelper.match_method?(m, include_s_methods, exclude_s_methods) }
        i_methods = (base.private_instance_methods + base.instance_methods).delete_if{|m| ! RinterceptorHelper.match_method?(m, include_i_methods, exclude_i_methods) }
        s_methods.each{|m| rinter_generate_proxy(base, m, include_s_methods.is_a?(Hash) ? include_s_methods : nil, true)}
        i_methods.each{|m| rinter_generate_proxy(base, m, include_i_methods.is_a?(Hash) ? include_i_methods : nil)}
        rinter_after_include_class(base)  #only available in last module for preparing data of Class which will include it
      else
        base.extend(ClassMethods)
      end
    end
    def rinter_here?
      true
    end
    
    #overridable only in last module
    def rinter_before_include_class(base)
    end
    
    #overridable only in last module
    def rinter_after_include_class(base)
    end
    
    def rinter_generate_proxy(obj, method, methods, singleton=false)
      handler = nil
      unless methods.nil?
        methods.each{|k, v| v.each{|vv| if method =~ vv then handler = method; break end }; unless handler.nil? then handler = k.nil? ? nil : "#{k}_"; break end}
        end
        obj.class_eval %{
        #{"class << self" if singleton}
        require "rinterceptor_invocation"
        alias_method :old4rinter_#{method}, :#{method} unless method_defined?(:old4rinter_#{method})
        def #{method}(*args)
          return old4rinter_#{method}(*args) if rinter_skip?
          rinter_before("#{method}", *args)
          result = nil
          e = nil
          invocation = RinterceptorInvocation.new(self, "#{method}", *args)
          begin
            result = rinter_#{handler}around(invocation)
          rescue => e
          end
          rinter_after("#{method}", result, e, *args)
          result
        end
        #{"end" if singleton}
      }
      end
      
      #target class' methods
      attr_accessor :include_i_methods
      attr_accessor :include_s_methods
      attr_accessor :exclude_i_methods
      attr_accessor :exclude_s_methods

     #overridable
     def rinter_skip?
	false 
     end
      
      #overridable
      def rinter_before(method, *args)
      end
      
      #overridable
      def rinter_after(method, result, e, *args)
        raise e unless e.nil?
        result
      end
      
      #overridable
      def rinter_around(invocation)
        invocation.invoke
      end
    end
  end
