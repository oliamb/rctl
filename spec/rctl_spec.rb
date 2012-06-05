require 'minitest/spec'
require 'minitest/autorun'

require 'rctl'

describe Rctl::Ctl do
  before do
    @re_help = /Usage\: rctl COMMAND \[OPTIONS\].*/
    @ctl = Rctl::Ctl.new({:config => File.expand_path(__FILE__ + '../../../lib/rctl/default_config.yml')})
  end
  
  it "should start no server if start command is passed without arguments" do
    res = @ctl.generate("start", [])
    res.wont_include 'start'
    res.must_equal ""
  end
  
  it "should start mysql server if a start command is passed with mysql service" do
    res = @ctl.generate("start", ['mysql'])
    res.must_match /echo '---> start mysql'/
    res.must_match /mysql.server start/
    res.must_equal "echo '---> start mysql' && mysql.server start"
  end
  
  it "should start two services if a start command is passed with mysql and mongodb" do
    res = @ctl.generate("start", ['mysql', 'mongodb'])
    res.must_match /echo '---> start mysql'/
    res.must_match /echo '---> start mongodb'/
  end
  
  it "should start two services in the right order even when passed in a different order" do
    @ctl.generate("start", ['mysql', 'unicorn']).must_match /mysql.*unicorn/
    @ctl.generate("start", ['unicorn', 'mysql']).must_match /mysql.*unicorn/
  end
  
  it "should stop the services in reverse order" do
    @ctl.generate("start", ['mysql', 'unicorn']).must_match /mysql.*unicorn/
    @ctl.generate("stop", ['mysql', 'unicorn']).must_match /unicorn.*mysql/
  end
end