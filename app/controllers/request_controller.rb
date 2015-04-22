# encoding: utf-8
require 'csv'


class RequestController < ApplicationController

  def index
    @search_word = 'товар'
  end

  def sql
    @sql_result = Product.find_by_sql("SELECT rubric_id, rubrics.title, COUNT(*) AS products_count
                                        FROM products
                                        INNER JOIN rubrics
                                        ON products.rubric_id = rubrics.id
                                        WHERE products.name LIKE '%#{params[:search_word]}%'
                                        GROUP BY rubric_id, rubrics.title
                                        ORDER BY products_count DESC;")

    save_csv @sql_result, "sql"
  end

  def arecord
    @arecord_result = Product.joins("INNER JOIN rubrics ON products.rubric_id = rubrics.id")
                              .select("rubric_id, rubrics.title, COUNT(*) AS products_count")
                              .where("products.name LIKE '%#{params[:search_word]}%'")
                              .group("rubric_id, rubrics.title")
                              .order("products_count DESC").all

    save_csv @arecord_result, "active_record"
  end

  def send_csv
    send_file "#{params[:method_type]}_result.csv"
  end


  private

  def save_csv(search_results, method_type)
    @filename = "#{method_type}_result.csv"

    CSV.open(@filename, 'w') do |csv|
      search_results.each { |row|
        csv << [row.rubric_id, row.title, row.products_count]
      }
    end
  end

end
