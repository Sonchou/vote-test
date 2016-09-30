require 'prawn'
class PdfQr < Prawn::Document
    
    def initialize
        super(:page_size => 'A4', :page_layout => :portrait, :margin => [0,0,0,0])
        render_table
    end
    
    def render_table
        font_families.update('ipa-mincho' => {normal: {file: 'ipaexm.ttf'}})
        font('ipaexm.ttf')
        pages = PdfQueue.count/44
        for page in 1..pages do
        zoom = 841.89 / 297.0
        for y in 0..10 do
            for x in 0..3 do
                draw_text "投票コード", :at => [(8.4+48.3*x+3.0)*zoom, (8.8+25.4*y+20.0)*zoom], :size => 10
                img = "app/assets/images/#{PdfQueue.last.path}"
                image img, :at => [(8.4+48.3*x+48.3-25.4)*zoom, (8.8+25.4*(y+1))*zoom], :width => 25.4*zoom
                PdfQueue.last.destroy
            end
        end
        if page < pages then start_new_page end
        end
    end
end
