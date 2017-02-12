module QualityAdjustment
  def self.adjust!(item)
    case item.name
    when /\AAged Brie\z/
      AppreciateIndefinitely
    when /\ABackstage passes/
      AppreciateWithCliff
    when /\ASulfuras/
      Constant
    when /\AConjured/
      DepreciateAccelerated
    else
      DepreciateNormal
    end.new(item).adjust!
  end

  class Base
    attr_reader :item

    def initialize(item)
      @item = item
    end

    def adjust!
      @item.sell_in -= 1
    end
  end

  class AppreciateIndefinitely < Base
    def adjust!
      super
      adjustment = @item.sell_in <= 0 ? 2 : 1
      @item.quality = [@item.quality + adjustment, 50].min
    end
  end

  class AppreciateWithCliff < Base
    def adjust!
      super

      if @item.sell_in < 0
        adjustment = -@item.quality
      elsif @item.sell_in < 5
        adjustment = 3
      elsif @item.sell_in < 10
        adjustment = 2
      else
        adjustment = 1
      end

      @item.quality = [@item.quality + adjustment, 50].min
    end
  end

  class Constant < Base
    def adjust!
    end
  end

  class DepreciateAccelerated < Base
    def adjust!
      super
      adjustment = @item.sell_in <= 0 ? -4 : -2
      @item.quality = [@item.quality + adjustment, 0].max
    end
  end

  class DepreciateNormal < Base
    def adjust!
      super
      adjustment = @item.sell_in <= 0 ? -2 : -1
      @item.quality = [@item.quality + adjustment, 0].max
    end
  end
end

def update_quality(items)
  items.each do |item|
    QualityAdjustment.adjust!(item)
  end
end

# DO NOT CHANGE THINGS BELOW -----------------------------------------

Item = Struct.new(:name, :sell_in, :quality)

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]

