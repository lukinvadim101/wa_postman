# require 'wa_sender'

desc 'WA Posts Manager'
task :run, [:path] do |_t, args|
  options = {}
  opts = OptionParser.new

  opts.on('-p', '--path ARG', String) { |path| options[:path] = path }

  args = opts.order!(ARGV) {}
  opts.parse!(args)

  Sender.new.(Store.new(options[:path]).data)
end

# rake run -- --path data/exm.csv
