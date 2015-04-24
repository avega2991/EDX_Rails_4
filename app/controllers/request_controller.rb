# encoding: utf-8
require 'csv'


class RequestController < ApplicationController

  def index
  end

  def sql
    @sql_result = Product.find_by_sql("SELECT rubric_id, rubrics.title, COUNT(*) AS products_count
                                        FROM products
                                        INNER JOIN rubrics
                                        ON products.rubric_id = rubrics.id
                                        WHERE products.name LIKE '%товар%'
                                        GROUP BY rubric_id, rubrics.title
                                        ORDER BY products_count DESC;")

    send_csv @sql_result, "sql"
  end

  def arecord
    @arecord_result = Product.joins("INNER JOIN rubrics ON products.rubric_id = rubrics.id")
                              .select("rubric_id, rubrics.title, COUNT(*) AS products_count")
                              .where("products.name LIKE '%товар%'")
                              .group("rubric_id, rubrics.title")
                              .order("products_count DESC").all

    send_csv @arecord_result, "active_record"
  end

  def sql_execute
    @sql_result = Product.connection.execute("SELECT rubric_id, rubrics.title, COUNT(*) AS products_count
                                                FROM products
                                                INNER JOIN rubrics
                                                ON products.rubric_id = rubrics.id
                                                WHERE products.name LIKE '%товар%'
                                                GROUP BY rubric_id, rubrics.title
                                                ORDER BY products_count DESC;")

    @filename = "sql_execute_result.csv"

    CSV.open(@filename, 'w') do |csv|
      @sql_result.each { |row|
        csv << [row['rubric_id'], row['title'], row['products_count']]
      }
    end

    send_file @filename
  end


  private

  def send_csv(search_results, method_type)
    @filename = "#{method_type}_result.csv"

    CSV.open(@filename, 'w') do |csv|
      search_results.each { |row|
        csv << [row.rubric_id, row.title, row.products_count]
      }
    end

    send_file @filename
  end

end
