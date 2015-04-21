# encoding: utf-8
require 'csv'


class RequestController < ApplicationController

  def index
  end

  def sql
    session[:request_result] =
        @sql_result = Product.find_by_sql("SELECT rubric_id, rubrics.title, COUNT(*) AS products_count
                                        FROM products
                                        INNER JOIN rubrics
                                        ON products.rubric_id = rubrics.id
                                        WHERE products.name LIKE '%товар%'
                                        GROUP BY rubric_id, rubrics.title
                                        ORDER BY products_count DESC;")

  end

  def arecord
    session[:request_result] =
        @arecord_result = Product.joins("INNER JOIN rubrics ON products.rubric_id = rubrics.id")
                              .select("rubric_id, rubrics.title, COUNT(*) AS products_count")
                              .where("products.name LIKE '%товар%'")
                              .group("rubric_id, rubrics.title")
                              .order("products_count DESC").all

  end

  def to_csv
    @request_result = session[:request_result]
    @method_type    = params[:method_type]
    @filename = "#{@method_type}_result.csv"

    CSV.open(@filename, 'w') do |csv|
      @request_result.each { |row|
        csv << [row.rubric_id, row.title, row.products_count]
      }
    end

    session[:request_result] = false
    redirect_to :action => 'index', :notice => "Saved to '#{@filename}'"

  end

end
