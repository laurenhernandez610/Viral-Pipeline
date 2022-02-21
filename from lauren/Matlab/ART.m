%% Alegbraic Reconstruction Technique 
% Repo from github 
% have not worked through yet


% x^(k+1) = x^(k) + lambda_(k) * AT( y - A( x ) ) / AT( A( ones(size(x)) ) )
    
% where,  A() is radon transform ( called by projection ) 
    
% AT() is inverse radon transform without filtration ( called by backprojection ).

  
%% Reference 
% https://en.wikipedia.org/wiki/Algebraic_reconstruction_technique

%%
function x  = ART(A,AT,b,x,lambda,n,bfig)

if (nargin < 7)
    bfig	= false;
end

if (nargin < 6)
    n       = 1e2;
end

ATA	= AT(A(ones(size(x), 'single')));

for i = 1:n
    
    x  	= x + lambda*AT(b - A(x))./ATA;
    
    if (bfig)
        figure(1); colormap gray;
        imagesc(x); title([num2str(i) ' / ' num2str(n)]);
        drawnow();
    end
end

x   = gather(x);

end