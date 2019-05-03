%%%%%%%% INICIO DO ALGORITIMO

 bs = 100;   % "bandsize"(Hz) , tamanho das faixas de freq
 nbs=80;    %num de bandas
 fs=16000;    % fornecendo o valor da freq de amost do sinal de audio
 g=zeros(1,80);
 l=zeros(1,80);
 
for k=0:700          %%%%%%%%%%%%%%%%%%%%   Loop for principal p/ cada uma das 701 janelas de 0.01s do sinal de audio (7.01 seg de audio analisados)
   
    x = audioread('C:\Users\andre iarozinski\Desktop\audios projeto\comfeed1.wav');  %%%% carregando arquivo do sinal de audio
       
   faixas=1:80;    %%%%%%%%%%%%% reiniciando os vetores de pico e desv padrao para uma nova comparacao a cada ciclo k
   faixas2=1:80;
   m=1:80;
   b=1:80;
    

   x = x(((fs*0.01*k)+1):(fs*0.01*(k+1)));        %%  coletando janelas da entrada/sinal a cada ciclo for"k" para analise,,, x(1:160) , x(161:320), ... x(1441:1600)

   S = fft(x);                          % transformada de janelas de 0.1s da entrada (x) ainda com espectro "duplo" sem unidades(Hz)

   L = length(S);                         % normalizando S
   P2 = abs(S/L);                            
   P = P2(1:L/2+1);
   P(2:end-1) = 2*P(2:end-1);                               % *** P é o módulo do espectro positivo de S com as amplitudes normalizadas, 8k ptos (0-8kHz)        
         
   f = fs*(0:(L/2))/L;                     % 16000=fs , agora com frequencia 0 até 8kHz 

                                              % a partir do vetor P, crio o vetor b
   for i=0:(nbs-1)
   
   b(i+1)= (sum(S(i*(bs/100)+1:(i+1)*(63/100))))/175;       % criando vetor b, contem a media das amplit p/ cada banda, b(1)=sum(P(1:80))/100,b(2)=sum(P(81:160))/100... 
   
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%% Loop de análise de pico
  
   
   [pks,locs] = findpeaks(b,'Threshold',0.001);  %% funcao que retorna valores de pico maiores que o definido e a sua posicao (band de freq)
   
   locs;                             %%% vetor com a posicao das faixas com pico, mas o vetor nao tem tamanho 50 ainda...
   locs=[locs 0];
   faixas=1:80;                     %%% criando vetor de tam 50 para armazenas os valores de "locs"
   for c=1:80
           if faixas(c)~=locs
                        faixas(c)=0;                        %%%%%% zerando faixas de frequencia em que nao foram consideradas pico pela funcao findpeaks
           end
           
    
   end

%%%%%%%%%%%%%%%%%%%% loops p/ analise do desvio padrao STD
   if k>1              
              
        faixas2=1:80;                             %% vetor de comparacao que zera os os valores das bandas que tem desv pad maior que 0.1

             v=[b;q];              %%% vetor variacao temporal do espectro de uma janela
                          
        for f=1:80
            ST(f)=std(v(:,f));   %%% cria o vetor do desv padrao entre b e q
        end

        for f=1:80
                if ST(f)>0.00005
                                   faixas2(f)=0;      %% vetor de comparacao que zera os os valores das bandas que tem desv pad maior que 0.1
                end
        end
        
   end

        q=b;       % armazenando vetor b p/ fazer varicao temp no proximo loop k

%%%%%%%%%%%%%%% se as 2 condicoes forem satisteitas p/ alguma banda, feedback detectado",,,  indicar banda, tempo da janela, e plotar fft com pico

   if k>1
      m=1:80;    %%%%% vetor p/ calcular diferenca , satistazer as 2 cond, bandas com pico e com desv pad menor que 0.1
    
   end
  for c=1:80
    a(c)=faixas(c)-faixas2(c);         %%%%% somente as bandas que satisfazem as 2 condicoes nao serao zeradas  2 0 8 0 -  0 1 8 3 =  2 -1 0 -3 
                 if a(c)~=0
                       m(c)=0;
                 end
                 if faixas(c)==0      %%%%%%%%%%% se alguma banda nao foi considerada pico, ela nao pode ser um feedback 
                       m(c)=0;
                 end
                  if faixas2(c)==0   %%%%%%%%%%%  se alguma banda nao teve desvio pad menor que o definido, ela nao pode ser um feedback
                       m(c)=0;
                 end
     end
 

     if (sum(m))~=0      %%%%% fazendo a soma do vetor g a cada loop 
               
        g=(g+m);
      
     end

 if (sum(g))>=200        %%%%%%%%% momento em que é detectada as frequencias instáveis
     if  (sum(g))<=300
     tempo=k/100;
     tempo       %%%%%% mostrando tempo de detecção
     end
 end

   

     end  %%%%%%%%%%%%%%% fim do loop principal
     
     for z=1:80       
     if g(z)<= 100
         g(z) = 0;
     end                  %%%% normalizando amplitudes finais p/1
     if g(z)>= 100
         g(z) = 1;
     end   
     end    

     d=1:80;  %% fator de escala p/ploatr ate 8kHz
     stem(d*bs,g)  %%% plotando bandas de frequencia com fb detectadas
