require 'yaml'
require 'pathname'

module Rctl
  class Ctl
    attr_reader :commands
    
    def initialize(options = {})
      if(options[:config])
        @commands = YAML.load_file(options[:config])
      else
        if(!File.exists? "~/.rctl.rc.yml")
          @commands = YAML.load_file(Pathname(__FILE__) + '../rctl/default_config.yml')
          File.open(File.expand_path("~/.rctl.rc.yml"), 'w') do |file|
            YAML.dump(@commands, file)
          end
        else
          @commands = YAML.load_file("~/.rctl.rc.yml")
        end
      end
      @start_order = define_start_order
    end
    
    # launch command on selected services.
    # return 0 if everything went ok.
    def generate(command = :start, services = {})
      generate_command(command, services)
    end
    
  private
    def define_start_order(remaining_server = nil)
      if(remaining_server.nil?)
        remaining_server = @commands.keys
      end
      ordered = []
      to_order = []
      remaining_server.each do |name|
        if (@commands[name]['dependencies'].nil? || @commands[name]['dependencies'].empty?) ||
           (@commands[name]['dependencies'].is_a?(Array) && (@commands[name]['dependencies'].select {|d| remaining_server.include?(d)}).count == 0) ||
           (! remaining_server.include?(@commands[name]['dependencies'].to_s))
          ordered.push name
        else
          to_order.push name
        end
      end
      
      if remaining_server.count == 0
        return ordered
      elsif remaining_server.count == to_order.count
          throw Exception.new("Circular dependencies in remaining server #{to_order}")
      else
        ordered.concat define_start_order(to_order)
      end
    end
    
    def help
      return "echo '#{@parser.to_s}'"
    end
    
    def generate_command(command, services)
      sw = @start_order.select {|s| services.include?(s)}
      sw.reverse! if command == 'stop'
      return(sw.map do |name|
        "echo '---> #{command} #{name.to_s}' && #{@commands[name][command]}"
      end.join(" && "))
    end
    
    # Build the parser given @@server_desc data
    def build_parser
      @parser = OptionParser.new do |opt|
        opt.banner = "Usage: rctl COMMAND [OPTIONS]"
        opt.separator ""
        opt.separator "Commands"
        opt.separator "    start   start server(s)"
        opt.separator "    stop    stop server(s)"
        opt.separator ""
        opt.separator "Options"

        opt.on("-a", "--all", "do COMMAND on all servers (by default)") { all }

        @commands.each do |name, args|
          opt.on("-#{args[:short]}", "--#{name.to_s}", "do COMMAND on #{name.to_s} server") do
            @server_switch.push name
          end
        end

        opt.on("-h", "--help", "help") do
          @usage = true
        end
      end
    end    
  end
end