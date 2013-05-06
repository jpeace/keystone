module Keystone
  module AssetTool
    def run(assets)
      assets.map do |asset| 
        if should_run?(asset)
          new_content = transform(asset)
          if new_content.is_a? Array
            new_type = new_content[0]
            new_content = new_content[1]
          end

          Asset.new do |a|
            a.name = asset.name
            a.type_history = asset.type_history
            a.type = new_type || asset.type
            a.path = asset.path
            a.namespace = asset.namespace
            a.location_on_disk = asset.location_on_disk
            a.content = new_content
          end
        else
          asset
        end
      end
    end

    private

    def should_run?(asset)
      true
    end

    def transform(asset)
      [asset.type, asset.content]
    end
  end
end