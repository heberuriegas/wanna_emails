select
	p.id as "Id",
	c.name as "Categoria",
	p.name as "Nombre",
	p.address as "Domicilio",
	p.postal_code as "Codigo postal",
	p.state as "Estado",
	p.country as "Pais",
	string_agg(DISTINCT(e.address), ',') as "Correos electronicos",
	string_agg(DISTINCT(ph.number), ',') as "Telefonos",
	string_agg(DISTINCT(pr.name), ',') as "Productos",
	p.hours as "Horario"
from prospects p
left join emails_prospects ep
	on p.id = ep.prospect_id
left join emails e
	on e.id = ep.email_id
left join products_prospects pp
	on pp.prospect_id = p.id
left join products pr
	on pr.id = pp.product_id
left join phones ph
	on ph.prospect_id = p.id
left join categories c
	on p.category_id = c.id
group by 
	p.id,
	c.name,
	p.name,
	p.address,
	p.hours,
	p.postal_code,
	p.country,
	p.state
;