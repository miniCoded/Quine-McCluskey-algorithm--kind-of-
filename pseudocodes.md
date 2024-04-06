SeleccionarMiniterminos

Inicio
	Lista tabla_verdad
	Lista mini_terminos
	T entrada
	Texto repr_binaria
	
	tabla_verdad = GenerarTablaVerdad(entrada)
	
	Por i = 0 hasta Tamaño(tabla_verdad)-1 hacer
		MiniTermino mini_terminos

		Si tabla_verdad[i] == '1' entonces
			repr_binaria = DecABin(i)
			Añadir(mini_terminos, MiniTermino.Nuevo(repr_binaria))
		Fin
	Fin

	Retornar mini_terminos
Fin



CombinarMiniterminos

Inicio
	Lista mini_terminos_inicial
	Lista mini_terminos_final

	Por siempre hacer
		Lista cubetas
		Entero ocurrencias

		cubetas = CrearCubetas(mini_terminos_inicial)
		mini_terminos_inicial = {}

		Por i = 0 hasta Tamaño(cubetas) - 2 hacer
			Lista cubeta_x = cubetas[i]
			Lista cubeta_y = cubetas[i+1]

			Por x = 0 hasta Tamaño(cubeta_x) - 1 hacer
				MiniTermino mx = cubeta_x[x]

				Por y = 0 hasta Tamaño(cubeta_y) - 1 hacer
					MiniTermino my = cubeta_y[y]

					Bool resultado
					MiniTermino combinado

					resultado, combinado = MiniTermino.Combinar(mx, my)

					Si resultado == True entonces
						ocurrencias = ocurrencias + 1
						Añadir(mini_terminos_inicial, combinado)
						mx.combinado = True
						my.combinado = True
					Fin
				Fin
			Fin
		Fin

		Por c en cubetas hacer
			Por m en c hacer
				Si no m.combinado entonces
					Añadir(mini_terminos_final, m)
				Fin
			Fin
		Fin

		Si ocurrencias == 0 entonces
			Romper
		Fin
	Fin

	Retornar mini_terminos_final
Fin



FiltrarMiniterminos

Inicio
	Lista numeros
	Entero i = 0

	Mientras i < Tamaño(mini_terminos_inicial) hacer
		MiniTermino m1 = mini_terminos_inicial[i]
		Entero ocurrencias
		Por n1 en m1.nums hacer
			Si Tamaño(numeros) == 0 entonces
				Añadir(numeros, n1)
			Si no
				Bool en_lista

				Por n2 en numeros hacer
					Si n1 == n2 entonces
						ocurrencias = ocurrencias + 1
						en_lista = True
					Fin
				Fin

				Si no en_lista entonces
					Añadir(numeros, n1)
				Fin
			Fin
		Fin

		Si ocurrencias >= Tamaño(m1.nums) entonces
			Remover(mini_terminos_inicial, m1)
		Si no
			i = i + 1
		Fin
	Fin
Fin


