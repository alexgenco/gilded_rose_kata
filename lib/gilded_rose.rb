module Quality
  def self.for_item(item)
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
    end.new(item)
  end

  class Base
    def initialize(item)
      @item = item
    end
  end

  class AppreciateIndefinitely < Base
    def next
      adjustment = @item.sell_in <= 0 ? 2 : 1
      [@item.quality + adjustment, 50].min
    end
  end

  class AppreciateWithCliff < Base
    def next
      if @item.sell_in <= 0
        adjustment = -@item.quality
      elsif @item.sell_in <= 5
        adjustment = 3
      elsif @item.sell_in <= 10
        adjustment = 2
      else
        adjustment = 1
      end

      [@item.quality + adjustment, 50].min
    end
  end

  class Constant < Base
    def next
      @item.quality
    end
  end

  class DepreciateAccelerated < Base
    def next
      adjustment = @item.sell_in <= 0 ? -4 : -2
      [@item.quality + adjustment, 0].max
    end
  end

  class DepreciateNormal < Base
    def next
      adjustment = @item.sell_in <= 0 ? -2 : -1
      [@item.quality + adjustment, 0].max
    end
  end
end

module SellIn
  def self.for_item(item)
    case item.name
    when /\ASulfuras/
      Constant
    else
      DecreaseNormal
    end.new(item)
  end

  class Base
    def initialize(item)
      @item = item
    end
  end

  class Constant < Base
    def next
      @item.sell_in
    end
  end

  class DecreaseNormal < Base
    def next
      @item.sell_in - 1
    end
  end
end

def update_quality(items)
  items.each do |item|
    item.quality = Quality.for_item(item).next
    item.sell_in = SellIn.for_item(item).next
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

