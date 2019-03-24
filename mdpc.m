classdef mdpc < mceliece_code
    %MDPC Moderate-Density Parity-Check codes class   
    
    properties
        r ;
        n ;
        n0 ;
        p ;
        w;
        g;
    end
    
    properties (Access = private)
        h;
    end
    
    methods 
        function obj = mdpc(params)
            %MDPC Construct an instance of this class
            %   Detailed explanation goes here
            
            if nargin<1 || isempty(params) 
                params = [2 137 14];
            end
            if ~isprime(params(2))
                me = MException('MDPC:wrongParam','Parameter P must be prime');
                me.throw;
                return ;
            end
            if mod(params(3),2) == 1
                params(3) = params(3)-1;
            end
            if mod(params(3)/2,2) == 0
                obj.w = params(3) - 2;
                disp(sprintf('Parameter w set to %d\n', obj.w));
            else
                obj.w = params(3);
            end
            obj.n = params(1)*params(2);
            obj.r = params(2);
            obj.n0 = params(1);
            obj.p = params(2);
            obj = obj.construct_matrices();
        end
        
        function y = encode(obj, x)
            %ENCODE Summary of this function goes here
            %   Detailed explanation goes here
            y = [];
            if length(x) ~= obj.n - obj.r
               display('Wrong message length');
               return;
            end
            
            y = mod(x*obj.g,2);
        end
        
        function x = decode(obj, y)
            %DECODE Decoding of Y vector
            %   Detailed explanation goes here
            x = [];
            if length(y) ~= obj.n
                me = MException('decode:wrongParam','Wrong codeword length');
                me.throw;
                return ;
              
            end        
            [x] = obj.BitFlip(y', 500);      
        end
                
        function [k n] = get_params(obj)
            n = obj.n;
            k = obj.n - obj.r;
        end    
    end
    
    methods (Access = private)
        
        function obj = construct_matrices(obj)
            %CONSTRUCT_MATRICES Constructing generator and parity-check 
            %matrices of MPDC-code
            %   OBJ = CONSTRUCT_MATRICES(OBJ)
            %
            
            h0 = [ones(1,obj.w/obj.n0) zeros(1,obj.p-obj.w/obj.n0)];
            h0 = [h0(randperm(obj.n/obj.n0)) h0(randperm(obj.n/obj.n0))];
         
            h = zeros(obj.r,obj.n);
            for i = 1: obj.r
                for j = 1:obj.n0
                    h(i,(j-1)*obj.p+1:j*obj.p) = circshift(h0(1,(j-1)*obj.p+1:j*obj.p),i);
                end
            end
            obj.h = h;
            
            g = zeros(obj.n-obj.r,obj.n);
            g = gf(g,1);
            
            for i = 1: obj.n0-1
                g((i-1)*obj.p+1:i*obj.p,obj.n-obj.r+1:obj.n)=...
                (inv(gf(h(:,(obj.n0-1)*obj.p+1:obj.n0*obj.p),1))...
                *gf(h(:,(i-1)*obj.p+1:i*obj.p),1))';
            end
            
            g(:,1:obj.n-obj.r) = gf(eye(obj.n-obj.r),1);
            obj.g = double(g.x);           
        end
        
        function vHat = BitFlip(obj, ci, iteration)
            % Hard-decision/bit flipping sum product algorithm LDPC decoder
            %
            %  rx        : Received signal vector
            %  H         : LDPC matrix
            %  iteration : Number of iteration
            %
            %  vHat      : Decoded vector (0/1) 
            %
            %
            % Copyright Bagawan S. Nugroho, 2007 
            % http://bsnugroho.googlepages.com

            [M N] = size(obj.h);
            ci = ci';         
            rji = zeros(M, N);
            qij = obj.h.*repmat(ci, M, 1);

            n = 1;
            s = mod(ci*obj.h',2);
            while n < iteration && nnz(s)~=0
               for i = 1:M
                  c1 = find(obj.h(i, :)); 
                  for k = 1:length(c1)
                     rji(i, c1(k)) = mod(sum(qij(i, c1)) + qij(i, c1(k)), 2);
                  end
               end 

               for j = 1:N
                  r1 = find(obj.h(:, j));
                  numOfOnes = length(find(rji(r1, j)));
                  
                  for k = 1:length(r1)        
                     if numOfOnes + ci(j) >= length(r1) - numOfOnes + rji(r1(k), j)
                        qij(r1(k), j) = 1;
                     else
                        qij(r1(k), j) = 0;
                     end

                  end % for k

                  if numOfOnes + ci(j) >= length(r1) - numOfOnes
                     vHat(j) = 0;
                  else
                     vHat(j) = 1;
                  end

               end % for j
               s = mod(vHat*obj.h',2);
               n = n + 1;
            end
            vHat = vHat(1,1:obj.n-obj.r);            
        end
    end
end

