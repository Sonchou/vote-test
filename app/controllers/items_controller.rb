require 'securerandom'
require 'rqrcode'
require 'rqrcode_png'
require 'chunky_png'
require 'rmagick'
class ItemsController < ApplicationController
    
    def new
    end
    
    def show
        render "items"
    end
    
    def index
        @parts = Participant.all
        @votes = Vote.all
    end
    
    def newvote
        number = params[:num].to_i
        voteid = params[:voteid]
        auth = params[:auth]
        code = VotingCode.find_by(voteid: voteid)
        if code.nil?
            render :text => "エラー：無効な投票id"
        else
            if auth == code.auth
                if code.enabled == true
                    code.update(enabled: false)
                    Vote.create(num: number, ip: request.ip)
                    redirect_to :action => "finish"
                else
                    redirect_to :action => "err_used"
                end
            else
                render :text => "エラー：認証に失敗"
            end
        end
    end
    
    def finish
    end
    
    def console
        if params[:akaza] != "akari"
            redirect_to :action => "index"
        end
        if params[:cmd] == "delall"
            VotingCode.delete_all
            redirect_to :action => "console", akaza: "akari"
        end
        if params[:cmd] == "clear"
            Vote.delete_all
            redirect_to :action => "console", akaza: "akari"
        end
        @votes = Vote.all
    end
    
    def add
        Participant.create(name: params[:name])
        redirect_to :action => "index"
    end
    
    def gencode
        pageurl = "http://takanawa.ddo.jp/"
        voteid = VotingCode.count.to_s
        auth = SecureRandom.hex(4)
        VotingCode.create(
            voteid: voteid,
            auth: auth,
            enabled: true)
        url = pageurl + "vote?voteid="+voteid+"&auth="+auth
        # QRコード生成
        qr = RQRCode::QRCode.new( url, :size => 8, :level => :h )
        png = qr.to_img
        png.resize(200, 200).save("app/assets/images/qr_#{voteid}.png")
        @qr = "qr_#{voteid}.png"
        @code = url
        render "gencode"
    end
    
    def vote
        @voteid = params[:voteid]
        @auth = params[:auth]
        
        voteid = params[:voteid]
        auth = params[:auth]
        code = VotingCode.find_by(voteid: voteid)
        if code.nil?
            render :text => "エラー：無効な投票id"
        else
            if auth == code.auth
                if code.enabled
                    @parts = Participant.all
                    @voteid = voteid
                else
                    redirect_to :action => "err_used"
                end
            else
                render :text => "エラー：認証に失敗"
            end
        end
    end
    
    def err_used
    end
    
    def pdf
    end
    
    def genpdf
        pageurl = "http://takanawa.ddo.jp/"
        @page = params[:page].to_i
        arrayQr = []
        arrayCode = []
        for _ in 1..@page*44 do
            voteid = VotingCode.count.to_s
            auth = SecureRandom.hex(4)
            VotingCode.create(
                voteid: voteid,
                auth: auth,
                enabled: true)
            url = pageurl + "vote?voteid="+voteid+"&auth="+auth
            # QRコード生成
            qr = RQRCode::QRCode.new( url, :size => 8, :level => :h )
            png = qr.to_img
            png.resize(200, 200).save("app/assets/images/qr_#{voteid}.png")
            arrayQr.push("qr_#{voteid}.png")
            PdfQueue.create(:path => "qr_#{voteid}.png")
            arrayCode.push(url)
        end
        @qr = arrayQr
        @code = arrayCode
        redirect_to :action => "getpdf"
    end
    
    def getpdf
        send_data PdfQr.new.render, filename: "code_#{VotingCode.count}.pdf", type: 'application/pdf'
    end
    
    def result
        if params[:akaza] != "akari"
            redirect_to :action => "index"
        end
        @parts = Participant.all
        @votes = Vote.all
    end
    
end
