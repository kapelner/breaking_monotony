module QualityAndAccuracyMetricsModule

  class QualityAndAccuracyMetrics

    def initialize(truth_points, user_points)
      raise "no truth set for image" if truth_points.nil?
      #immediately convert the raw string data into usable points objects
      @truth_points = truth_points.blank? ? [] : truth_points.map{|p| PointXY.new(p)}
      @user_points = user_points.blank? ? [] : user_points.map{|p| PointXY.new(p)}
    end
    
    def calculate_precision_recall_tp_fp_fn(r)
      copy_truth_points = @truth_points.map{|p| p} #deep copy
      tp = 0

      @user_points.each do |up|
        break if copy_truth_points.empty? #we've gone through all the points
        min_distance_sqd_and_its_point = min_distance_away(copy_truth_points, up)
        if min_distance_sqd_and_its_point.first <= r ** 2
          tp += 1 #bump up true positives
          copy_truth_points.delete(min_distance_sqd_and_its_point.last) #kill point in truth points array
        end
      end
      
      fp = @user_points.length - tp #the points the user made save the truth points
      fn = copy_truth_points.length #whatever truth points are left at this point, the user did not find
      #return both precision and recall (see http://en.wikipedia.org/wiki/Precision_and_recall)
      return [0, 0] if (tp.zero? and fp.zero?) or (tp.zero? and fn.zero?) #avoid the 0 / 0 error
      [tp / (tp + fp).to_f, tp / (tp + fn).to_f, tp, fp, fn]
    end

    MaxDistanceToBeCounted = 10 #10 pixels away - over that, it's all over
    def calculate_sum_of_sqd_distances
      copy_truth_points = @truth_points.map{|p| p} #deep copy
      ssds = 0
      @user_points.each do |up|
        break if copy_truth_points.empty? #we've gone through all the points
        min_distance_sqd_and_its_point = min_distance_away(copy_truth_points, up)
        next if min_distance_sqd_and_its_point.first > MaxDistanceToBeCounted ** 2
        ssds += min_distance_sqd_and_its_point.first
        copy_truth_points.delete(min_distance_sqd_and_its_point.last) #kill point in truth points array
      end
      ssds
    end

    def calculate_sum_of_distances
      copy_truth_points = @truth_points.map{|p| p} #deep copy
      sds = 0
      points_to_distances = {}
      @user_points.each do |up|
        break if copy_truth_points.empty? #we've gone through all the points
        min_distance_sqd_and_its_point = min_distance_away(copy_truth_points, up)
        next if min_distance_sqd_and_its_point.first > MaxDistanceToBeCounted ** 2
        d = min_distance_sqd_and_its_point.first ** 0.5
        sds += d
        copy_truth_points.delete(min_distance_sqd_and_its_point.last) #kill point in truth points array
        points_to_distances[min_distance_sqd_and_its_point.last] = d
      end
      [sds, points_to_distances]
    end

    private
    #returns both the closest true point and its associated distance sqd away
    def min_distance_away(truth_points, up)
      truth_points.inject([]){|arr, p| arr << [up.sqd_distance(p), p]; arr}.min{|a, b| a.first <=> b.first}
    end
  end

  class PointXY
    def initialize(str)
      @x, @y = str.split(',')
    end
    def x
      @x.to_f
    end
    def y
      @y.to_f
    end
    def sqd_distance(p)
      (self.x - p.x) ** 2 + (self.y - p.y) ** 2
    end
    def <=>(pt)
      y_compare = (self.y <=> pt.y)
      y_compare == 0 ? (self.x <=> pt.x) : y_compare
    end
    def to_s
      "#{@x},#{@y}"
    end
  end
end

