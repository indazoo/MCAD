	function matrix_3x3_determinant(matrix) = 
		  	A[0][0]*(A[1][1]*A[2][2]-A[2][1]*A[1][2])
     		-A[0][1]*(A[1][0]*A[2][2]-A[1][2]*A[2][0])
      	+A[0][2]*(A[1][0]*A[2][1]-A[1][1]*A[2][0]);
			
	function matrix_3x3_transposed_inversed(A) =
		//http://stackoverflow.com/a/984286
		let(invdet = 1/matrix_3x3_determinant(A)
				)
		[
			[
				(A[1][1]*A[2][2]-A[2][1]*A[1][2])*invdet //result(0,0)
			 -(A[1][0]*A[2][2]-A[1][2]*A[2][0])*invdet //result(0,1)
				(A[1][0]*A[2][1]-A[2][0]*A[1][1])*invdet //result(0,2)
			],[                                        
			 -(A[0][1]*A[2][2]-A[0][2]*A[2][1])*invdet //result(1,0)
			  (A[0][0]*A[2][2]-A[0][2]*A[2][0])*invdet //result(1,1)
			 -(A[0][0]*A[2][1]-A[2][0]*A[0][1])*invdet //result(1,2)
			 ],[                                       
			  (A[0][1]*A[1][2]-A[0][2]*A[1][1])*invdet //result(2,0)
			 -(A[0][0]*A[1][2]-A[1][0]*A[0][2])*invdet //result(2,1)
			  (A[0][0]*A[1][1]-A[1][0]*A[0][1])*invdet //result(2,2)
			]
		];		
		
	function matrix_3x3_inversed(A) =
		//http://stackoverflow.com/a/18504573
		//https://en.wikipedia.org/wiki/Invertible_matrix
		let(invdet = 1/matrix_3x3_determinant(A)
				)
		[
			[
				(A[1][1]*A[2][2]-A[2][1]*A[1][2])*invdet //minv(0, 0)
			 -(A[0][2]*A[2][1]-A[0][1]*A[2][2])*invdet //minv(0, 1)
				(A[0][1]*A[1][2]-A[0][2]*A[1][1])*invdet //minv(0, 2)
			],[                                        
			 -(A[1][2]*A[2][0]-A[1][0]*A[2][2])*invdet //minv(1, 0)
			  (A[0][0]*A[2][2]-A[0][2]*A[2][0])*invdet //minv(1, 1)
			 -(A[1][0]*A[0][2]-A[0][0]*A[1][2])*invdet //minv(1, 2)
			 ],[                                       
			  (A[1][0]*A[2][1]-A[2][0]*A[1][1])*invdet //minv(2,0)
			 -(A[2][0]*A[0][1]-A[0][0]*A[2][1])*invdet //minv(2,1)
			  (A[0][0]*A[1][1]-A[1][0]*A[0][1])*invdet //minv(2,2)
				]
		];