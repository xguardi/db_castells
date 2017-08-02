require 'rubygems'
require 'mechanize'
require 'sqlite3'
require 'digest'
require 'ruby-progressbar'

# Useful functions
def escape_characters_in_string(string)
  string.gsub(/"/, '\'')
end


db = SQLite3::Database.new 'db/bdcj.db'

# Precarreguem el llistat de castells
castells = Hash.new
rs = db.execute("SELECT * FROM castells")
rs.each do |row|
castells[row[0]] = row[1]
end

agent = Mechanize.new
page = agent.get('http://www.cccc.cat/base-de-dades')

# Parsejem els noms de totes les colles i els seus ids i ho guardem també en BD
options = page.search("select[name='filters[idColla][]'] option")
colles = Hash.new
# Eliminem la primera opció que és buida
options.shift
for option in options
  sql = "INSERT INTO Colles VALUES(\"" + option.attributes['value'].value.to_s + "\", \"" + option.children[0].text.strip!.to_s + "\")"
  # print(sql)
  # db.execute sql 
  colles[option.attributes['value'].value] = option.children[0].text.strip!
end

# Iterem per totes les colles
progressbar = ProgressBar.create(:starting_at => 1, :total => colles.length)
for c in 1..(colles.length)
  # for c in 7..7

  target = colles.keys[c - 1]
  # puts c.to_s + " " + target

  # advance progress bar
  progressbar.progress = c
  progressbar.log target

  page = agent.get('http://www.cccc.cat/base-de-dades')
  # Fixem els paràmetres del formulari
  form = page.form('form')
  # Data d'inici i final
  form.fields[0].value = '01/01/2014'
  form.fields[1].value = '31/12/2014'
  # Tipus de resultats descriptius
  form.radiobuttons_with(:name => 'tipus')[0].check
  # Colla
  form.fields[4].value = target

  # Fem el submit
  response = agent.submit(form, form.button_with(:value => 'BUSCAR'))

  # Guardem el nou formulari
  form = response.form('formPag')
  # Busquem la pàgina màxima de paginació (1 2 3 4 5) => 5
  if response.search(".pagination-nums").length > 0
    max_page = response.search(".pagination-nums").children.last.attributes["value"].text.to_i
  else
    max_page = 1
  end

  # Iterem sobre totes les pàgines (paginació)
  # for page in 1..1
  for page in 1..max_page
    # puts(page.to_s + "/" + max_page.to_s + "\n")
    if max_page > 1
      form = response.form('formPag')
      response = agent.submit(form, form.button_with(:value => page.to_s))
    else
      form = response.form('form')
      response = agent.submit(form, form.button_with(:value => 'BUSCAR'))
    end
    # Processem la resposta
    # Busquem l'àncora (el tag on comencen el resultats)
    anchor = response.search("//div[@style='margin-top:10px;']")[0]

    # Primer comprobem que tinguem resultats
    if anchor.search("div.alert").length > 0
      # puts "No hi ha resultats"
    else
      # Iterem sobre totes les diades
      for result in anchor.search("div")
        s = result.text.strip!
        s = escape_characters_in_string(s)
        # puts "s: " + s
        if s.length > 10
          data = s[6,4] + s[3,2] + s[0,2]
          s = s[11,s.length].strip!
          s = s.split(',')
          nom = s[0]
          if s.length > 1
            lloc = s[1]
          else
            lloc = ''
          end
          # puts "nom: " + nom
          # puts "lloc: " + lloc 
          # Per calcular el hash, com que es poden repetir el nom+lloc+data, afegim tb la taula html amb els castells
          diada_id = Digest::MD5.hexdigest(nom + lloc + data + result.next_sibling.next_sibling.to_s)
          begin
            # Guardem la diada
            db.execute "INSERT INTO diades (id, data, nom, lloc) VALUES(\"" + diada_id  + "\",\"" + data + "\",\"" + nom + "\",\"" + lloc + "\")"
            # Si la diada s'ha creat correctament (no la tenim ja duplicada) procedim
            # a iterar sobre els castells...
            # Taules amb els resultats
            table = result.next_sibling.next_sibling
            for tr in table.search("tr")
              cells = tr.search("td")
              # Busquem el id de colla
              if cells[0].text.strip! != ''
                colla_id = colles.key(cells[0].text.strip!)
              end
              # Busquem el id del castell
              castell_id = castells.key(cells[1].text.strip!)
              if castell_id.nil?
                puts 'Castell desconegut: ' + cells[1].text.strip!.to_s
              end
              # Busqume el status del castell
              status_desc = cells[2].text.strip!
              status = "D" if status_desc == "Descarregat"
              status = "C" if status_desc == "Carregat" 
              status = "ID" if status_desc == "Intent desmuntat"
              status = "I" if status_desc == "Intent"
              # info
              # puts diada_id + " " + colla_id.to_s + " " + castells[castell_id].to_s + " " + status
              db.execute "INSERT INTO castells_executats (diada_id, colla_id, castell_id, status) 
    VALUES('" + diada_id.to_s  + "','" + colla_id.to_s + "'," + castell_id.to_s + ",'" + status + "')"
            end
          rescue SQLite3::Exception => e 
            # puts e
          end
        end
      end
    end # Hi ha resultats
  end
end # colles

# Tanquem la connexió amb la BD
db.close

