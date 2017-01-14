module FeaturesMixins
  def self.included(base)
    base.extend(ClassMethods)
  end

  def add_feature(feature)
    features << feature
    save
  end

  def remove_feature(feature)
    self.features = features - [feature]
    save
  end

  def has_feature?(feature)
    features.include?(feature)
  end

  module ClassMethods
    # adds a feature to all
    def add_feature(feature)
      all.each do |t|
        t.add_feature(feature)
      end
    end

    def remove_feature(feature)
      all.each do |t|
        t.remove_feature(feature)
      end
    end
  end
end
