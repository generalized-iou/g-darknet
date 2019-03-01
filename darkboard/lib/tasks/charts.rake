namespace :charts do
  desc "update all"
  task :update => :environment do
    sync_from = ENV['SYNC_FROM'] || '/cvgl2/u/ntsoi/src/nn/darknet/backup'
    sync_to = ENV['SYNC_TO'] || '/scr/ntsoi/darknet/'
    unless ENV['NOSYNC']
      cmd = "rsync --update -raz --progress #{sync_from} #{sync_to} --exclude '*.backup' --exclude '*.weights'"
      puts("syncing with '#{cmd}'")
      IO.popen(cmd) { |io| while (line = io.gets) do puts line end }
    end
    puts("updating charts")
    Experiment.update_charts
  end
end
