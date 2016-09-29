require 'prawn'
class PdfQr < Prawn::Document
    
    def initialize
        super(page_size: 'A4', page_layout: :portrait)
        render_table
    end
    
    def render_table
        font_families.update('ipa-mincho' => {normal: {file: 'ipaexm.ttf'}})
        font('ipaexm.ttf')
        text "こころぴょんぴょん"
    end
end
