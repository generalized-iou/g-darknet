require 'fileutils'

class Experiment < ApplicationRecord
  serialize :chart

  CHART_DATAPOINT_LIMIT = 10000

  def self.backup_dir
    Rails.root.join('..', 'backup')
  end

  def self.by_name name
    ret = nil
    path = self.backup_dir.join(name)
    self.new(name: name, path: path).tap do |experiment|
      log_path = logpath(path)
      hidefile = hidepath(path)
      if File.exists?(hidefile)
        experiment.is_hidden = true
      end
      if File.exists?(log_path) && !experiment.is_hidden
        ret = {
          #log_created_at: File.ctime(log_path),
          #log_modified_at: File.mtime(log_path),
          id: experiment.name,
          name: experiment.name,
          subtitle: experiment.subtitle,
          is_hidden: experiment.is_hidden,
          notes: experiment.notes,
          path: path,
        }
      end
    end
    return ret
  end

  COLORS = %w/
    #FF4081
    #993D5C
    #D000FF
    #F3FF40
    #CCBD14
    #00CAFF
    #CCBD14
  /
  def self.from_disk
    res = []
    Dir.glob(Rails.root.join('..', 'backup', '*')).select{|f| File.directory? f}.each do |path|
      exp =  self.by_name(File.basename(path))
      unless exp.nil? || exp[:hidden]
        res << exp
      end
    end
    i = 0;
    res.sort_by{|r| r[:name]}.reverse.map do |r|
      r[:color] = COLORS[i%COLORS.count] 
      i += 1
      r
    end
  end

  def self.parse_log_csv_line line
    a,b = line.split(',BATCH,')
    return if b.nil?
    sums_counts = {}
    a.split(',').each do |v|
      k = v[0]
      next if k.nil?
      # currently: [A, I, G, C, T]
      k = 'A' if k =~ /\d/
      k = k.to_sym
      if sums_counts[k].nil?
        sums_counts[k] = {sum: 0, count: 0}
      end
      sums_counts[k][:sum] += v[1..-1].to_f
      sums_counts[k][:count] += 1
    end
    current_batch, max_batch, total_cost = b.split(',')
    res = {
      current_batch: current_batch.to_i,
      max_batch: max_batch.to_i,
      vals: {
        total_cost: total_cost.to_f
      }
    }
    sums_counts.each do |k, sc|
      res[:vals][k] = sc[:sum]/sc[:count]
    end
    res
  end

  def self.logpath path
    File.join(path, 'log.csv')
  end

  def self.hidepath path
    File.join(path, '_HIDE')
  end

  def self.mappath path
    File.join(path, 'map.txt')
  end

  def chartdatapath
    File.join(self.class.backup_dir, self.name, 'chartdata.json')
  end

  def hide
    FileUtils.touch(hidepath(path))
  end

  def get_chart
    if File.exists?(chartdatapath)
      self.chart = JSON.parse(File.read(chartdatapath))
    else
      update_chart
    end
    self
  end

  def self.update_charts
    self.from_disk.each do |experiment|
      Experiment.new(experiment).update_chart
    end
  end

  # Only updates if there has been a change
  def update_chart
    if File.exists?(chartdatapath)
      chart = JSON.parse(File.read(chartdatapath))
      mtimechart = Time.parse(chart['mtime'])
      mtimenow = File.mtime(self.class.logpath(self.path))
      if mtimechart.present? && mtimechart >= mtimenow
        puts("(#{chartdatapath} and #{self.path}), same timestamp (#{mtimechart}, #{mtimenow}), returning existing chart")
        return chart 
      end
    end
    i = 0
    chart_types = %w/A I G C T/.map{|t| t.to_sym}
    chart = {
      max_batch: 0,
      by_type: {}
    }
    chart_types.each{|t| chart[:by_type][t] = []}
    File.readlines(self.class.logpath(self.path)).each do |line|
      unless (l = self.class.parse_log_csv_line(line)).nil?
        chart[:max_batch] = l[:max_batch] if l[:max_batch] > chart[:max_batch]
        chart_types.each do |t|
          chart[:by_type][t] << [l[:current_batch], l[:vals][t]] unless l[:vals][t].nil?
        end
      end
      i += 1
    end
    # loss charts relative to total loss
    total_loss_type = :T
    %w/I C/.map{|t| t.to_sym}.each do |t|
      chart[:by_type]["#{t}_R"] = chart[:by_type][t].each_with_index.map do |entry, j|
        rel_los = (entry[1]/chart[:by_type][total_loss_type][j][1])
        loss = if t == :I
          1 - rel_los
        else
          rel_los
        end
        [entry[0], loss]
      end
    end

    %w/iou giou val2017-iou val2017-giou/.map{|t| chart[:by_type][t.to_sym] = []}
    if File.exists?(self.class.mappath(self.path))
      prev_batches = []
      File.readlines(self.class.mappath(self.path)).each do |line|
        cols = line.split(',')
        type = cols[0]
        batch = cols[1].to_i
        mean_mAP = cols[2].to_f
        # estimate final batch number
        if batch.to_i == 9223372036854775807
          if prev_batches.length >= 2
            batch = prev_batches[-1] + (prev_batches[-2] - prev_batches[-1]).abs
          elsif prev_batches.length >= 1
            batch = prev_batches[-1] + 100
          else
            batch = 700
          end
        end
        prev_batches << batch if prev_batches.last != batch
        chart[:by_type][type.to_sym] << [batch, mean_mAP]
      end

      chart[:by_type].each do |type, arr|
        if (size = arr.size) > CHART_DATAPOINT_LIMIT
          puts("slicing chart #{type} from #{arr.size} down to #{CHART_DATAPOINT_LIMIT}")
          chart[:by_type][type] = arr.each_slice(size/CHART_DATAPOINT_LIMIT).map{|sub_arr| sub_arr.first}
        end
      end
    end
    chart['mtime'] = File.mtime(self.class.logpath(self.path))
    puts("rebuilt #{self.name} at #{chart['mtime']}")
    self.chart = chart
    self.last_line_read += i
    File.open(chartdatapath, 'wb'){|f| f.write(chart.to_json)}
    self
  end
end
