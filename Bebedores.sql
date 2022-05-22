-- #1: Bebedores a los que le gusta la malta
select b.*
from bebedor b
where exists (
	select b1.*, g.*
	from bebida b1, gusta g
	where b1.nombre = 'malta'
	and g.ci = b.ci
	and g.codbeb = b1.codbeb
)

-- #2: fuentes de soda no frecuentadas por Luis Perez	
select f.*
from fuentesoda f
where not exists (
	select f1.*
	from frecuenta f1
	where f1.codfs = f.codfs
	and exists (
		select b.*
		from bebedor b
		where b.nombre = 'LP'
		and b.ci = f1.ci
	)
)

-- #3: Bebedores a los que les gusta al menos una bebida y frecuentan al menos una FS
select b.*
from bebedor b
where exists(
	select g.*
	from gusta g where g.ci = b.ci
	)
and exists (
	select f.*
	from frecuenta f where f.ci = b.ci
	)

-- #4: Para cada bebedor, las bebidas que no le gustan
select b1.*, b2.*
from bebedor b1, bebida b2
where not exists (
	select g.*
	from gusta g
	where g.ci = b1.ci
	and g.codbeb = b2.codbeb
)

-- #5: bebedores a los que les gusta la malta y no les gusta la frescolita ni la cocacola
select b.*
from bebedor b
where exists (
	select g.*
	from gusta g
	where g.ci = b.ci and
	exists (
		select b1.*
		from bebida b1
		where b1.codbeb = g.codbeb
		and b1.nombre = 'malta'
	)
)
and not exists (
	select g1.*
	from gusta g1
	where g1.ci = b.ci and
	exists (
		select b2.*
		from bebida b2
		where b2.codbeb = g1.codbeb
		and b2.nombre = 'frescolita'
	)
)
and not exists (
	select g2.*
	from gusta g2
	where g2.ci = b.ci and
	exists (
		select b3.*
		from bebida b3
		where b3.codbeb = g2.codbeb
		and b3.nombre = 'cocacola'
	)
)

-- #6: Los bebedores a los que no les gustan las bebidas que le gustan a LP
	-- no le gustan ninguna de las bebidas que le gustan a LP:
select b.*
from bebedor b
where not exists (
	select g.*
	from gusta g
	where g.ci = b.ci
	and exists (
		select g1.*
		from gusta g1
		where g1.codbeb = g.codbeb
		and exists (
			select b1.*
			from bebedor b1
			where b1.ci = g1.ci
			and b1.nombre = 'LP'
		)
	)
)
	
-- #7 Los bebedores que frecuentan las FS que frecuenta LP (todas)
select b.*
from bebedor b
where not exists (
	select fs.*
	from fuentesoda(fs)
	where exists (
		select f.*
		from frecuenta f
		where f.codfs = fs.codfs
		and exists (
			select b1.*
			from bebedor b1
			where b1.nombre = 'LP'
			and f.ci = b1.ci
		)
	)
	and not exists (
		select f.*
		from frecuenta f
		where f.ci = b.ci
		and f.codfs = fs.codfs
	)
)

-- #8: Los bebedores que frecuentan algunas de las FS que frecuenta LP (al menos una)
select b.*
from bebedor b
where exists (
	select f.*
	from frecuenta f
	where exists (
		select b1.*
		from bebedor b1
		where b1.nombre = 'LP'
		and b1.ci = f.ci
	)
	and exists (
		select f1.*
		from frecuenta f1
		where f1.ci = b.ci
		and f1.codfs = f.codfs
	)
)

-- #9 Los bebedores que frecuentan sólo las fuentes de soda que frecuenta Luis Pérez. (todas y únicamente esas)
select b.*
from bebedor b
where not exists (
	select f.*
	from frecuenta f
	where exists (
		select b1.*
		from bebedor b1
		where b1.nombre = 'LP'
		and b1.ci = f.ci
	)
	and not exists (
		select f1.*
		from frecuenta f1
		where f1.ci = b.ci
		and f1.codfs = f.codfs
	)
)
and not exists (
	select f.*
	from frecuenta f
	where f.ci = b.ci
	and not exists (
		select f1.*, b1.*
		from frecuenta f1, bebedor b1
		where b1.ci = f1.ci
		and f1.codfs = f.codfs
		and b1.nombre = 'LP'
	)
)

-- #10: Los bebedores que frecuentan alguna fuente de soda que sirve al menos una bebida que les guste.
select b.*
from bebedor b
where exists (
	select f.*
	from frecuenta f
	where f.ci = b.ci
	and exists (
		select v.*
		from vende v
		where v.codfs = f.codfs
		and exists (
			select g.*
			from gusta g
			where g.ci = b.ci
			and g.codbeb = v.codbeb
		)
	)
)

-- #11: Los bebedores que frecuentan fuentes de soda que sirven al menos todas las bebidas que les gustan.
select b.*
from bebedor b
where exists (
	select f.*
	from frecuenta f
	where f.ci = b.ci
	and not exists (
		select g.*
		from gusta g
		where g.ci = b.ci
		and not exists (
			select v.*
			from vende v
			where v.codbeb = g.codbeb
			and v.codfs = f.codfs
		)
	)
)

-- #12: Bebedores que solo frecuentan las FS que sirven las bebidas que les gusten
select b.*
from bebedor b
where not exists (
	select f.*
	from frecuenta f
	where f.ci = b.ci
	and exists (
		select g.*
		from gusta g
		where g.ci = b.ci
		and not exists (
			select v.*
			from vende v
			where v.codbeb = g.codbeb
			and v.codfs = f.codfs
		)
	)
)

-- #13: bebedores que solo frecuentan las FS que solo sirven algunas de las bebidas que les gustan
select b.*
from bebedor b
where not exists (
	select f.*
	from frecuenta f
	where f.ci = b.ci
	and exists (
		select v.*
		from vende v
		where v.codfs = f.codfs
		and not exists (
			select g.*
			from gusta g
			where g.ci = b.ci
			and g.codbeb = v.codbeb
		)
	)
)

-- #14: Bebedores que no frecuentan las FS que sirven al menos una bebida que no les guste
select b.*
from bebedor b
where not exists (
	select f.*
	from frecuenta f
	where f.ci = b.ci
	and exists (
		select v.*
		from vende v
		where v.codfs = f.codfs
		and exists (
			select b2.*
			from bebida b2
			where b2.codbeb = v.codbeb
			and not exists (
				select g.*
				from gusta g
				where g.codbeb = b2.codbeb
				and g.ci = b.ci
			)
		)
	)
)

-- #15: Bebedores que frecuentan todas las FS que sirven todas las bebidas que le gustan a LP

	-- fs que vende todas las bebidas que le gustan a LP
select fs.*
from fuentesoda fs
where not exists (
	select g.*
	from gusta g
	where not exists (
		select b.*
		from bebedor b
		where b.nombre = 'LP'
		and b.ci = g.ci
		and exists (
			select v.*
			from vende v
			where v.codfs = fs.codfs
			and v.codbeb = g.codbeb
		)
	)
)
		--

select b.*
from bebedor b
where not exists (
	select fs.*
	from fuentesoda fs
	where not exists (
		select g.*
		from gusta g
		where not exists (
			select b.*
			from bebedor b
			where b.nombre = 'LP'
			and b.ci = g.ci
			and exists (
				select v.*
				from vende v
				where v.codfs = fs.codfs
				and v.codbeb = g.codbeb
			)
		)
	)
	and not exists (
		select f.*
		from frecuenta f
		where f.codfs = fs.codfs
		and f.ci = b.ci
	)
)

-- #16: Bebedores a quienes les gustan todas las bebidas que sirven en todas las FS que frecuentan
select b.*
from bebedor b
where not exists (
	select b1.*
	from bebida b1
	where exists (
		select f.*
		from frecuenta f
		where f.ci = b.ci
		and exists (
			select v.*
			from vende v
			where v.codfs = f.codfs
			and v.codbeb = b1.codbeb
		)
		and not exists (
			select g.*
			from gusta g
			where g.ci = b.ci
			and g.codbeb = b1.codbeb
		)
	)
)

-- #17: Bebedores a quienes les gustan solo las bebidas que sirven en las FS que frecuentan
select b.*
from bebedor b
where not exists (
	select b1.*
	from bebida b1
	where exists (
		select f.*
		from frecuenta f
		where f.ci = b.ci
		and exists (
			select v.*
			from vende v
			where v.codfs = f.codfs
			and v.codbeb = b1.codbeb
		)
		and not exists (
			select g.*
			from gusta g
			where g.ci = b.ci
			and g.codbeb = b1.codbeb
		)
	)
) and not exists (
	select g.*
	from gusta g
	where g.ci = b.ci
	and not exists (
		select f.*
		from frecuenta f
		where f.ci = b.ci
		and exists (
			select v.*
			from vende v
			where v.codfs = f.codfs
			and v.codbeb = g.codbeb
		)
	)
)

-- #18: Bebidas que les gustan a las personas a quienes les gusta la malta
select b.*
from bebida b
where exists (
	select b1.*
	from bebedor b1
	where exists (
		select b2.*
		from bebida b2
		where b2.nombre = 'malta'
		and exists (
			select g.*
			from gusta g
			where g.codbeb = b2.codbeb
			and g.ci = b1.ci
		)
	)
	and exists (
		select g.*
		from gusta g
		where g.ci = b1.ci
		and g.codbeb = b.codbeb
	)
)

-- #19: FS frecuentadas por (todas) las personas a quienes les gusta la malta
select fs.*
from fuentesoda fs
where not exists (
	select b.*
	from bebedor b
	where exists (
		select g.*
		from gusta g
		where g.ci = b.ci
		and exists (
			select b1.*
			from bebida b1
			where b1.nombre = 'malta'
			and g.codbeb = b1.codbeb
		)
	)
	and not exists (
		select f.*
		from frecuenta f
		where f.ci = b.ci
		and f.codfs = fs.codfs
	)
)

-- #20: Las fuentes de soda que no venden ninguna de las bebidas que venden en las fuentes de soda frecuentadas por Luis Pérez.
	-- Bebidas que venden en las FS frecuentadas por LP:
select b.*
from bebida b
where exists (
	select fs.*
	from fuentesoda fs
	where exists (
		select f.*
		from frecuenta f
		where f.codfs = fs.codfs
		and exists (
			select b1.*
			from bebedor b1
			where b1.nombre = 'LP'
			and b1.ci = f.ci
		)
		and exists (
			select v.*
			from vende v
			where v.codfs = fs.codfs
			and v.codbeb = b.codbeb
		)
	)
)
	--
select fs.*
from fuentesoda fs
where not exists (
	select v.*
	from vende v
	where v.codfs = fs.codfs
	and exists (
		select b.*
		from bebida b
		where b.codbeb = v.codbeb
		and exists (
			select fs1.*
			from fuentesoda fs1
			where exists (
				select f.*
				from frecuenta f
				where f.codfs = fs1.codfs
				and exists (
					select b1.*
					from bebedor b1
					where b1.nombre = 'LP'
					and b1.ci = f.ci
				)
				and exists (
					select v1.*
					from vende v1
					where v1.codbeb = b.codbeb
					and v1.codfs = fs1.codfs
				)
			)
		)
	)
)

-- #21: Bebedores a quienes no les gustan al menos dos de las bebidas que le gustan a LP (les gusta una o ninguna)
select b.*
from bebedor b
where not exists (
	select b1.*
	from bebida b1
	where exists (
		select g.*, b2.*
		from gusta g, bebedor b2
		where b2.nombre = 'LP'
		and g.ci = b2.ci
		and g.codbeb = b1.codbeb
		and exists (
			select g1.*
			from gusta g1
			where g1.codbeb = b1.codbeb
			and g1.ci = b.ci
		)
	)
) or (
	select count(*)
	from bebida b1
	where exists (
		select g.*, b2.*
		from gusta g, bebedor b2
		where b2.nombre = 'LP'
		and g.ci = b2.ci
		and g.codbeb = b1.codbeb
		and exists (
			select g1.*
			from gusta g1
			where g1.codbeb = b1.codbeb
			and g1.ci = b.ci
		)
	)
) = 1



-- #22: Bebedores a quienes no les gusta ninguna bebida pero frecuentan al menos una FS
select b.*
from bebedor b
where not exists (
	select g.*
	from gusta g
	where g.ci = b.ci
)
and exists (
	select f.*
	from frecuenta f
	where f.ci = b.ci
)

-- #23: Para cada bebedor, las fuentes de soda que no frecuentan y las bebidas que no les gustan.
select b.*, b1.*, fs.*
from bebedor b, bebida b1, fuentesoda fs
where not exists (
	select g.*
	from gusta g
	where g.codbeb = b1.codbeb
	and g.ci = b.ci
) and not exists (
	select f.*
	from frecuenta f
	where f.codfs = fs.codfs
	and f.ci = b.ci
)

-- #24: Para cada bebida, las personas a quienes les gusta y las fuentes de soda que la sirven.
select b.*, beb.*, fs.*
from bebida b, bebedor beb, fuentesoda fs
where exists (
	select g.*
	from gusta g
	where g.ci = beb.ci
	and g.codbeb = b.codbeb
) and exists (
	select v.*
	from vende v
	where v.codbeb = b.codbeb
	and v.codfs = fs.codfs
)

-- #25: Bebidas que son vendidas por al menos una FS pero que no existe persona a la que le guste
select b.*
from bebida b
where exists (
	select fs.*
	from fuentesoda fs
	where exists (
		select v.*
		from vende v
		where v.codbeb = b.codbeb
		and v.codfs = fs.codfs
	)
)
and not exists (
	select b1.*
	from bebedor b1
	where exists (
		select g.*
		from gusta g
		where g.ci = b1.ci
		and g.codbeb = b.codbeb
	)
)

-- #26: Las bebidas que venden en al menos dos de las FS frecuentadas por LP
select b.*
from bebida b
where (
	select count(*)
	from vende v
	where v.codbeb = b.codbeb
	and exists (
		select *
		from frecuenta f, bebedor b1
		where v.codfs = f.codfs
		and b1.nombre = 'LP'
		and f.ci = b0.ci
	)
) > '1'

-- #27: Las bebidas que se sirven en las fuentes de soda que son frecuentadas por las personas que les gusta la malta.
select beb.*
from bebida beb
where not exists (
	select fs.*
	from fuentesoda fs
	where not exists (
		select b.*
		from bebedor b
		where exists (
			select g.*
			from gusta g
			where g.ci = b.ci
			and exists (
				select b1.*
				from bebida b1
				where b1.nombre = 'malta'
				and g.codbeb = b1.codbeb
			)
		)
		and not exists (
			select f.*
			from frecuenta f
			where f.ci = b.ci
			and f.codfs = fs.codfs
		)
	)
	and not exists (
		select v.*
		from vende v
		where v.codfs = fs.codfs
		and v.codbeb = beb.codbeb
	)
)

-- #28: Las bebidas que se sirven en las fuentes de soda que son frecuentadas por las personas que no les gusta la malta.
select beb.*
from bebida beb
where not exists (
	select fs.*
	from fuentesoda fs
	where not exists (
		select b.*
		from bebedor b
		where not exists (
			select g.*
			from gusta g
			where g.ci = b.ci
			and exists (
				select b1.*
				from bebida b1
				where b1.nombre = 'malta'
				and g.codbeb = b1.codbeb
			)
		)
		and not exists (
			select f.*
			from frecuenta f
			where f.ci = b.ci
			and f.codfs = fs.codfs
		)
	)
	and not exists (
		select v.*
		from vende v
		where v.codfs = fs.codfs
		and v.codbeb = beb.codbeb
	)
)

-- #29: Las fuentes de soda que son frecuentadas por las personas a las que les gusta la malta y frecuentan la fuente de soda ”La Montaña”.
select fs.*
from fuentesoda fs
where not exists (
	select b.*
	from bebedor b
	where exists (
		select f.*, fs1.*
		from frecuenta f, fuentesoda fs1
		where fs1.nombre = 'la montana'
		and f.ci = b.ci
		and f.codfs = fs1.codfs
	)
	and exists (
		select g.*, b1.*
		from gusta g, bebida b1
		where b1.nombre = 'malta'
		and g.ci = b.ci
		and g.codbeb = b1.codbeb
	)
	and not exists (
		select f.*
		from frecuenta f
		where f.ci = b.ci
		and f.codfs = fs.codfs
	)
)

-- #30: La bebida más servida entre las fuentes de soda que frecuenta Luis Pérez.
	-- La bebida más vendida entre todas las FS:
select b.*
from bebida b
where not exists (
	select b1.*
	from bebida b1
	where b != b1
	and (
		(select count(*)
		from vende v
		where v.codbeb = b1.codbeb)
	 >=
		(select count(*)
		from vende v1
		where v1.codbeb = b.codbeb)
	)
)
	--
	
select b.*
from bebida b
where exists (
	select fs.*
	from fuentesoda fs
	where exists (
		select f.*, beb.*
		from frecuenta f, bebedor beb
		where beb.nombre = 'LP'
		and f.ci = beb.ci
		and f.codfs = fs.codfs
	)
	and not exists (
		select b1.*
		from bebida b1
		where b != b1
		and (
			(select count(*)
			from vende v
			where v.codbeb = b1.codbeb
			and v.codfs = fs.codfs)
		 >=
			(select count(*)
			from vende v1
			where v1.codbeb = b.codbeb
			and v1.codfs = fs.codfs)
		)
	)
)

-- #31: La fuente de soda que sirve malta y es la más frecuentada.
select fs.*
from fuentesoda fs
where exists (
	select v.*, b.*
	from vende v, bebida b
	where b.nombre = 'malta'
	and v.codbeb = b.codbeb
	and v.codfs = fs.codfs
)
and not exists (
		select fs1.*
		from fuentesoda fs1
		where fs != fs1
		and exists (
			select v.*, b.*
			from vende v, bebida b
			where b.nombre = 'malta'
			and v.codfs = fs1.codfs
			and v.codbeb = b.codbeb
		)
		and (
			(select count(*)
			from frecuenta f
			where f.codfs = fs1.codfs)
			>=
			(select count(*)
			from frecuenta f1
			where f1.codfs = fs.codfs)
		)
)

-- #32: El bebedor a quien más bebidas le gustan y más fuentes de soda frecuenta.
select b.*
from bebedor b
where not exists (
	select b1.*
	from bebedor b1
	where b != b1
	and (
		(select count(*)
		 from frecuenta f
		 where f.ci = b1.ci)
		>
		(select count(*)
		from frecuenta f1
		where f1.ci = b.ci)
	)
)
and not exists (
	select b1.*
	from bebedor b1
	where b != b1
	and (
		(select count(*)
		 from gusta g
		 where g.ci = b1.ci)
		>
		(select count(*)
		from gusta g1
		where g1.ci = b.ci)
	)
)

-- #33: Para cada bebida, cuál es el número de fuentes de soda que la sirven y el número de personas a quien le gustan.
	-- no se puede traducir a calculo relacional sin funcion de agregacion

-- #34: Las fuentes de soda que venden a menor precio la malta.
select fs.*
from fuentesoda fs
where exists (
	select v.*, b.*
	from vende v, bebida b
	where b.nombre = 'malta'
	and v.codfs = fs.codfs
	and v.codbeb = b.codbeb
	and not exists (
		select fs1.*
		from fuentesoda fs1
		where exists (
			select v1.*, b1.*
			from vende v1, bebida b1
			where b1.nombre = 'malta'
			and v1.codfs = fs1.codfs
			and v1.codbeb = b1.codbeb
			and v1.precio < v.precio
		)
	)
)

-- #35: El precio promedio de venta de la malta en las fuentes de sodas frecuentadas por Luis Perez
	-- se necesita funcion de agregacion (avg)

-- #36: La bebida más cara en las fuentes de soda que no venden al menos una de las bebidas que le gusta a Luis Pérez.
select b.*
from bebida b
where not exists (
	select fs.*
	from fuentesoda(fs)
	where exists (
		select b1.*
		from bebida b1
		where exists (
			select g.*
			from gusta g
			where g.codbeb = b1.codbeb
			and exists (
				select b2.*
				from bebedor b2
				where b2.nombre = 'LP'
				and b2.ci = g.ci
			)
		)
		and not exists (
			select v.*
			from vende v
			where v.codbeb = b1.codbeb
			and v.codfs = fs.codfs
		)
	)
	and not exists (
		select v.*
		from vende v
		where v.codfs = fs.codfs
		and v.codbeb = b.codbeb
	)
) and not exists (
	select b1.*
	from bebida b1
	where not exists (
		select fs.*
		from fuentesoda fs
		where exists (
			select b2.*
			from bebida b2
			where exists (
				select g.*
				from gusta g
				where g.codbeb = b2.codbeb
				and exists (
					select beb.*
					from bebedor beb
					where beb.nombre = 'LP'
					and beb.ci = g.ci
				)
			) and not exists (
				select v.*
				from vende v
				where v.codbeb = b2.codbeb
				and v.codfs = fs.codfs
			)
		)
		and not exists (
			select v.*
			from vende v
			where v.codfs = fs.codfs
			and v.codbeb = b1.codbeb
		)
	) and exists (
		select v1.*
		from vende v1
		where v1.codbeb = b1.codbeb
		and not exists (
			select v.*
			from vende v
			where v.codbeb = b.codbeb
			and v.precio >= v1.precio
		)
	)
)
	
-- #37: Los bebedores a quienes les gusta la bebida más cara vendida por las fuentes de soda que venden malta.
select b.*
from bebedor b
where not exists (
	select b1.*
	from bebida b1
	where not exists (
		select fs.*
		from fuentesoda(fs)
		where exists (
			select v.*
			from vende v
			where v.codfs = fs.codfs
			and exists (
				select b2.*
				from bebida b2
				where b2.nombre = 'malta'
				and b2.codbeb = v.codbeb
			)
		) and not exists (
			select v.*
			from vende v
			where v.codfs = fs.codfs
			and v.codbeb = b1.codbeb
		)
	) and not exists (
		select b2.*
		from bebida b2
		where not exists (
			select fs.*
			from fuentesoda(fs)
			where exists (
				select v.*
				from vende v
				where v.codfs = fs.codfs
				and exists (
					select b3.*
					from bebida b3
					where b3.nombre = 'malta'
					and b3.codbeb = v.codbeb
				)
			)
		) and exists (
			select v.*
			from vende v
			where v.codbeb = b2.codbeb
			and not exists (
				select v1.*
				from vende v1
				where v1.codbeb = b1.codbeb
				and v1.precio >= v.precio
			)
		)
	) and not exists (
		select g.*
		from gusta g
		where g.codbeb = b1.codbeb
		and g.ci = b.ci
	)
)


-- #38: Las fuentes de soda que venden las bebidas que no le gustan a Luis Pérez y que le gustan José Pérez.
select fs.*
from fuentesoda fs
where not exists (
	select b.*
	from bebida b
	where exists (
		select b1.*
		from bebedor b1
		where b1.nombre = 'LP'
		and not exists (
			select g.*
			from gusta g
			where g.ci = b1.ci
			and g.codbeb = b.codbeb
		)
	) and exists (
		select b2.*
		from bebedor b2
		where b2.nombre = 'JP'
		and exists (
			select g.*
			from gusta g
			where g.ci = b2.ci
			and g.codbeb = b.codbeb
		)
	) and not exists (
		select v.*
		from vende v
		where v.codbeb = b.codbeb
		and v.codfs = fs.codfs
	)
)

-- #39: No se puede hacer (avg)
-- #40: No se puede hacer (avg)

-- #41: Los bebedores que frecuentan al menos 3 fuentes de soda que sirven alguna bebida que les gusta.
select b.*
from bebedor b
where (
	select count(*)
	from frecuenta f
	where f.ci = b.ci
	and exists (
		select v.*
		from vende v
		where v.codfs = f.codfs
		and exists (
			select g.*
			from gusta g
			where g.ci = g.ci
			and g.codbeb = v.codbeb
		)
	)
) >= 3

-- #42: Las fuentes de soda que son frecuentadas por al menos dos bebedores que le gustan al menos 3 de las bebidas que sirven.
select fs.*
from fuentesoda fs
where (
	select count(*)
	from frecuenta f
	where f.codfs = fs.codfs
	and exists (
		select b.*
		from bebedor b
		where f.ci = b.ci
		and (
			select count(*)
			from gusta g
			where g.ci = b.ci
			and exists (
				select v.*
				from vende v
				where v.codfs = fs.codfs
				and v.codbeb = g.codbeb
			)
		) >= 3
	)
) >= 2

-- #43: Los bebedores que no frecuentan fuentes de sodas que sirven al menos una bebida que les gusta.
select b.*
from bebedor b
where not exists (
	select fs.*
	from fuentesoda fs
	where exists (
		select v.*, g.*
		from vende v, gusta g
		where g.ci = b.ci
		and v.codbeb = g.codbeb
		and v.codfs = fs.codfs
	)
	and exists (
		select f.*
		from frecuenta f
		where f.ci = b.ci
		and f.codfs = fs.codfs
	)
)

-- #44: Las fuentes de soda que no sirven bebidas que no le gustan a al menos uno de los bebedores que la frecuentan.
	-- no le gustan a al menos uno: no le gustan a ninguno
select fs.*
from fuentesoda fs
where not exists (
	select v.*
	from vende v
	where v.codfs = fs.codfs
	and exists (
		select f.*
		from frecuenta f
		where f.codfs = fs.codfs
		and not exists (
			select g.*
			from gusta g
			where g.ci = f.ci
			and g.codbeb = v.codbeb
		)
	)
)

-- #45: Las fuentes de soda que son frecuentadas sólo por bebedores que no les gustan al menos una de las bebidas que éstos sirven.
select fs.*
from fuentesoda fs
where exists (
	select f.*
	from frecuenta f
	where f.codfs = fs.codfs
	and exists (
		select v.*
		from vende v
		where v.codfs = fs.codfs
		and not exists (
			select g.*
			from gusta g
			where g.ci = f.ci
			and g.codbeb = v.codbeb
		)
	)
) and not exists (
	select f.*
	from frecuenta f
	where f.codfs = fs.codfs
	and exists (
		select v.*
		from vende v
		where v.codfs = fs.codfs
		and exists (
			select g.*
			from gusta g
			where g.ci = f.ci
			and g.codbeb = v.codbeb
		)
	)
)

-- #46: Las fuentes de soda que son frecuentadas por el (los) bebedores que le(s) gustan el mayor número de bebidas.
select fs.*
from fuentesoda fs
where not exists (
	select b.*
	from bebedor b
	where not exists (
		select b1.*
		from bebedor b1
		where b != b1
		and (
			(select count(*)
			 from gusta g
			 where g.ci = b1.ci)
			>
			(select count(*)
			from gusta g1
			 where g1.ci = b.ci)
		)
	) and not exists (
		select f.*
		from frecuenta f
		where f.codfs = fs.codfs
		and f.ci = b.ci
	)
)

-- #47: La(s) bebida(s) que más gusta(n).
select b.*
from bebida b
where not exists (
	select b1.*
	from bebida b1
	where (
		(select count(*)
		from gusta g
		where g.codbeb = b1.codbeb)
		>
		(select count(*)
		from gusta g1
		where g1.codbeb = b.codbeb)
	)
)

-- #48: Las fuentes de soda que sirven la(s) bebida(s) que más gusta(n).
select fs.*
from fuentesoda fs
where exists (
	select v.*
	from vende v
	where v.codfs = fs.codfs
	and exists (
		select b.*
		from bebida b
		where v.codbeb = b.codbeb
		and not exists (
			select b1.*
			from bebida b1
			where (
				(select count(*)
				from gusta g
				where g.codbeb = b1.codbeb)
				>
				(select count(*)
				from gusta g1
				where g1.codbeb = b.codbeb)
			)
		)
	)
)

-- #49: Las bebidas que son vendidas por la(s) FS más frecuentadas y que le(s) gusta(n) a los bebedor(es) que más le(s) gustan bebidas.
select b.*
from bebida b
where not exists (
	select fs.*
	from fuentesoda fs
	where not exists (
		select fs1.*
		from fuentesoda fs1
		where (
			(select count(*)
			from frecuenta f
			where f.codfs = fs1.codfs)
			>
			(select count(*)
			from frecuenta f1
			where f1.codfs = fs.codfs)
		)
	)
	and not exists (
		select v.*
		from vende v
		where v.codfs = fs.codfs
		and v.codbeb = b.codbeb
	)
)
and not exists (
	select b1.*
	from bebedor b1
	where not exists (
		select b2.*
		from bebedor b2
		where b1 != b2
		and (
			(select count(*)
			from gusta g
			where g.ci = b2.ci)
			>
			(select count(*)
			from gusta g1
			where g1.ci = b1.ci)
		)
	)
	and not exists (
		select g.*
		from gusta g
		where g.ci = b1.ci
		and g.codbeb = b.codbeb
	)
)

-- #50: Las bebidas que son servidas en las fuentes de soda más frecuentadas y que le gustan al menor número de bebedores.
select b.*
from bebida b
where not exists (
	select fs.*
	from fuentesoda fs
	where not exists (
		select fs1.*
		from fuentesoda fs1
		where fs != fs1
		and (
			(select count(*)
			from frecuenta f
			where f.codfs = fs1.codfs)
			>
			(select count(*)
			from frecuenta f1
			where f1.codfs = fs.codfs)
		)
	)
	and not exists (
		select v.*
		from vende v
		where v.codfs = fs.codfs
		and v.codbeb = b.codbeb
	)
) and not exists (
	select b1.*
	from bebida b1
	where b != b1
	and (
		(select count(*)
		from gusta g
		where g.codbeb = b1.codbeb)
		<
		(select count(*)
		from gusta g1
		where g1.codbeb = b.codbeb)
	)
)