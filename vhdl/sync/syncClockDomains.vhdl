--
-- Synchronizes Clock Domains
-- This core solves the communication between components working at different frequencies.
--
-- Author(s):
-- * Rodrigo A. Melo
-- * Based in a Gaisler's mechanism used in the GRLib IP library http://www.gaisler.com/
--
-- Copyright (c) 2009-2015 Authors and INTI
-- Distributed under the BSD 3-Clause License
--

---------------------------------------------------------------------------------------------------
--
-- SyncClockDomains sirve para sincronizar 2 dispositivos que trabajan a diferentes clocks.
--
---------------------------------------------------------------------------------------------------
-- Solución de Gaisler
---------------------------------------------------------------------------------------------------
--
-- La siguiente solución es la utilizada por Gaisler en el core Ethernet de la GRLib (GReth). Está
-- incrustado en el código por todos lados y no utiliza los nombres aquí dados a las señales.
--
-- Se tiene un coreA, que trabaja a una frecuencia clkA, que habilita al coreB, que trabaja a clkB,
-- mediante una señal x. Esta señal, trabaja por cambio de estado y no generando simplemente un
-- pulso, ya que en varias oportunidades o no se llegaría a detectar, si clkA > clkB, o se
-- detectaría varias veces, si clkA < clkB. En el coreB, en cada flanco ascendente de clkB, una
-- señal x' copia el estado de x. A su vez, una señal de ack (acknowledge) del coreB al coreA, se
-- asigna en cada clkB con el valor x'.
--
-- Supongamos inicialmente que tanto x, como x' y ack, arrancan en '0'. Ahora el coreA coloca x a
-- '1'. El coreB, en el siguiente flanco de subida de clkB, asignará x' a '1', y en el que le
-- sigue, asignará ack a '1'. En coreB, de hacer un XOR entre x' y ack, se obtienen los pulsos de
-- habilitación enaB que el core precise. En coreA, una vez que se observa el ack, se pasa a '1'
-- una señal ack' y en el siguiente clkA se pasa a '1' un ack''. Con estas 2 se logran los pulsos
-- de habilitación enaA que el coreA precise. Para este punto, todas las señales que se manejan por
-- cambio de nivel quedaron a '1' y el coreA esta listo para reiniciar el ciclo colocando x a '0'.
--
-- Un diagrama de señales para verlo mas claro:
--         ____  ____  ____  ____
-- clkA  __I  I__I  I__I  I__I  I__I  } El coreA, a su frecuencia clkA,
--         _________________________  } pasa x a '1'.
-- x     __I                          }
--
--           _____    _____    _____
-- clkB  ____I   I____I   I____I   I  } El coreB, a su frecuencia clkB,
--           _______________________  } una vez que detecta x='1', coloca
-- x'    ____I                        } x' a '1'.
--                    ______________  }
-- ack   _____________I               } En el siguiente clkB, ack pasa a '1'.
--           __________               }
-- enaB  ____I        I_____________  } Del XOR entre x' y ack se obtiene enaB.
--
--         ____  ____  ____  ____
-- clkA  __I  I__I  I__I  I__I  I__I  } El coreA, a su frecuencia clkA,
--                     _____________  } una vez que detecta ack='1', coloca
-- ack'  ______________I              } ack' a '1'.
--                           _______  }
-- ack'' ____________________I        } En el siguiente clkA, ack'' pasa a '1'.
--                     _______        }
-- enaA  ______________I     I______  } Del XOR entre ack' y ack'' se obtiene enaA.
--
--
-- Del método descripto usado por Gaisler, se observa que no se utiliza directamente el cambio de
-- estado en x para generar la habilitación en coreB en el primer clkB, sino que primero se usa un
-- flip flop para obtener x' y luego esta señal se utiliza para la habilitación. Esto es así para
-- reducir problemas de metaestabilidad. Además, el core de Gaisler, mediante un generic, permite
-- seleccionar si se utiliza un solo flip flop de sincronismo o 2, dado más flip flops en cascadas,
-- más probable es recuperarse de una situación de metaestabilidad.
--
---------------------------------------------------------------------------------------------------
-- Metaestabilidad. Según Wikipedia
---------------------------------------------------------------------------------------------------
--
-- Los circuitos electrónicos digitales basan su funcionamiento en la manipulación mediante álgebra
-- binaria de los niveles lógicos 0 y 1, que físicamente se corresponden con niveles de tensión,
-- típicamente tierra y tensión de alimentación.
-- Uno de los componentes básicos empleados en los circuitos digitales son los biestables. Estos
-- componentes tienen la facultad de retardar señales binarias, permitiendo al circuito memorizar
-- estados.
-- Los biestables requieren para su funcionamiento que se les alimente con una señal periódica de
-- reloj, que les indica cuándo han de muestrear la señal a su entrada. Si esta señal de entrada
-- conmuta (cambia de valor) justo en el instante de muestreo, el biestable capturará un valor
-- intermedio entre las tensiones correspondientes a los niveles lógicos 0 y 1. Este estado en el
-- cual un biestable almacena un nivel lógico no válido se denomina estado metaestable, y puede
-- provocar que el circuito digital opere de forma inesperada o errónea.
-- El estado metaestable, aunque teóricamente puede mantenerse indefinidamente, siempre acabará
-- resolviéndose en un valor lógico válido 0 o 1, aunque no es posible saber cuánto tiempo tardará.
-- Un diseño cuidadoso del componente biestable asegurará que el tiempo medio de resolución sea lo
-- suficientemente bajo como para evitar que pueda poner en peligro el funcionamiento correcto del
-- circuito. Técnicas de diseño de más alto nivel, como el uso de circuitos sincronizadores
-- consistentes en varios biestables en cascada, o de circuitos de handshake, dan mayor robustez al
-- diseño frente al problema de la metaestabilidad, minimizando la probabilidad de que suceda hasta
-- un nivel despreciable. Pese a todo, en circuitos digitales complejos de varios cientos de miles
-- de puertas lógicas y varias señales de reloj asíncronas entre sí, como los presentes en todos
-- los chips digitales que se fabrican en la actualidad, evitar los estados metaestables es un
-- desafío que requiere gran cuidado por parte del diseñador.
--
---------------------------------------------------------------------------------------------------
-- El Core implementado
---------------------------------------------------------------------------------------------------
--
-- La idea fue reflejar el comportamiento usado por Gaisler en un componente, teniendo como
-- objetivo la reutilización y versatilidad del mismo, y esclarecer código donde sea utilizado.
--
-- La caja negra (entity) del mismo y su descripción
--                _________
--                I       I
--  clkA_i ------>I       I<------ clkB_i
--                I       I
--  a_i    ------>I       I------> b_o
--                I       I
--  ack_o  <------I       I
--                I_______I
--  rst_i  -----------^
--
-- * La interfaz A, es la del componente que indica algo al otro y recibe el ack.
-- * La interfaz B, es la del componente que recibe la indicación.
-- * clkA_i y clkB_i son las señales de clock de las interfases A y B.
-- * a_i es la llamada x en la descripción del método de Gaisler, mientras que b_o y ack_o son las
--   llamadas enaB y enaA en dicha descripción.
-- * rst_i es la señal de reset, que deberá ser manejada por el componente que haya instanciado al
--   core (no es exclusivo del lado A o B).
--
-- Nota: la idea del core es que sea instanciado solo en uno de los 2 cores involucrados en la
-- comunicación, o en su defecto, en ninguno de los 2 sino en una descripción que los incluya.
--
-- Generics:
--
-- - INBYLEVEL (INput BY LEVEL, boolean):
--   Indica el tipo de señalización de a_i.
--   FALSE: a_i funciona como pulso de habilitación (valor por defecto).
--   TRUE : a_i funciona por cambio de nivel.
-- - FFSTAGES (Flip Flop STAGES, natural):
--   Indica la cantidad de flip flops a utilizar para la generación de b_o y
--   ack_o, ante un suceso en a_i.
--   Su valor mínimo es 0 y no tiene límite superior. 2 es su valor por defecto.
--   Nota: no utilizar flip flops no es recomendable por la alta probabilidad de
--   problemas de metaestabilidad, pero es agregado para poder realizar pruebas
--   de laboratorio.
-- - CHANNELS (positive):
--   Las señales a_i, b_o y ack_o, son del tipo std_logic_vector. Este GENERIC especifica su tamaño
--   y representa la cantidad de canales a utilizar. Se utiliza para resolver varias comunicaciones
--   con una sola instanciación del componente. 1 es su valor por defecto y el mínimo posible.
--
-- Modo de uso:
--
-- 1 - Incluir la librería
-- library FPGALIB;
-- use FPGALIB.sync.all;
--
-- 2 - Instanciación
-- Para el caso de un solo canal, se puede utilizar el componente SyncClockDomainsBase. El mismo
-- no cuenta con el Generic CHANNELS.
--
--   SCDB: SyncClockDomainsBase
--      generic map(INBYLEVEL => INBYLEVEL, FFSTAGES => FFSTAGES)
--      port map(
--         rst_i => rst_i, clkA_i => clkA , clkB_i => clkB,
--         a_i => entrada, b_o => salida, ack_o => acknowledge
--      );
--
-- Para el caso de más de un canal. Se utiliza el Generic CHANNEL para especificar la cantidad de
-- los mismos a utilizar.
--
-- Los puertos a_i, b_o y ack_o, pasan a ser del tipo std_logic_vector(CHANNELS downto 0)
--
-- * Ejemplo 1:
--
--   Ejemplo1: SyncClockDomains
--      generic map(CHANNELS => 2)
--      port map(
--         rst_i    => rst,     clkA_i   => clkA,  clkB_i => clkB,
--         a_i(0)   => ch1_a,   a_i(1)   => ch2_a,
--         b_o(0)   => ch1_b,   b_o(1)   => ch2_b,
--         ack_o(0) => ch1_ack, ack_o(1) => ch2_ack
--      );
--
-- En este caso, directamente en la instanciación asocio los puertos a las señales que quiero
-- utilizar.
--
-- * Ejemplo 2:
--
--   Ejemplo2: SyncClockDomains
--      generic map(CHANNELS => 2)
--      port map(
--         rst_i => rst, clkA_i => clkA, clkB_i => clkB,
--         a_i => entradas, b_o => salidas, ack_o => acknowledges
--      );
--
-- En este caso, los puertos se asocian a señales del mismo tipo que los puertos y se pueden
-- utilizar directamente manejando un subíndice o asignar a las señales que se precisen.
--
-- 3 - Algoritmo de utilización.
-- a) El coreA señaliza determinado suceso mediante el puerto a_i.
-- b) El coreB recibirá un pulso de habilitación mediante b_o.
-- c) El coreA recibirá el reconocimiento de que el coreB procesó la información mediante el puerto
--    ack_o y queda listo para la siguiente operación.
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity SyncClockDomainsBase is
   generic(
      INBYLEVEL : boolean:=FALSE; -- Input By Level
      FFSTAGES  : natural:= 2     -- Flip Flop Stages
   );
   port(
      rst_i  : in  std_logic;
      clka_i : in  std_logic;
      clkb_i : in  std_logic;
      a_i    : in  std_logic;
      b_o    : out std_logic;
      ack_o  : out std_logic
   );
end entity SyncClockDomainsBase;

architecture RTL of SyncClockDomainsBase is
   signal a          : std_logic:='0';
   signal acka, ackb : std_logic_vector(FFSTAGES downto 0):=(others => '0');
begin

   in_by_level:
   if INBYLEVEL generate
      a <= a_i;
   end generate in_by_level;

   in_no_level:
   if not INBYLEVEL generate
      sideA_in:
      process (clka_i)
      begin
         if rising_edge(clka_i) then
            if rst_i = '1' then
               a <= '0';
            else
               if a_i = '1' then
                  a <= not(a);
               end if;
            end if;
         end if;
      end process sideA_in;
   end generate in_no_level;

   sideB:
   process (clkb_i)
   begin
      if rising_edge(clkb_i) then
         if rst_i = '1' then
            ackb <= (others => '0');
         else
            ackb(0) <= a;
            if FFSTAGES > 0 then
               for i in 0 to FFSTAGES-1 loop
                   ackb(i+1) <= ackb(i);
               end loop;
            end if;
         end if;
      end if;
   end process sideB;

   sideA:
   process (clka_i)
   begin
      if rising_edge(clka_i) then
         if rst_i = '1' then
            acka <= (others => '0');
         else
            acka(0) <= ackb(FFSTAGES);
            if FFSTAGES > 0 then
               for i in 0 to FFSTAGES-1 loop
                   acka(i+1) <= acka(i);
               end loop;
            end if;
         end if;
      end if;
   end process sideA;

   WITHOUT_FF:
   if FFSTAGES = 0 generate
      b_o   <= a xor ackb(0);
      ack_o <= ackb(0) xor acka(0);
   end generate WITHOUT_FF;

   WITH_FF:
   if FFSTAGES /= 0 generate
      b_o   <= ackb(FFSTAGES-1) xor ackb(FFSTAGES);
      ack_o <= acka(FFSTAGES-1) xor acka(FFSTAGES);
   end generate WITH_FF;

end architecture RTL;

---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
library FPGALIB;
use FPGALIB.Sync.all;

entity SyncClockDomains is
   generic(
      INBYLEVEL : boolean:=FALSE; -- Input By Level
      FFSTAGES  : natural:= 2;    -- Flip Flop Stages
      CHANNELS  : positive:= 1    -- Channels
   );
   port(
      rst_i  : in  std_logic;
      clkA_i : in  std_logic;
      clkB_i : in  std_logic;
      a_i    : in  std_logic_vector(CHANNELS-1 downto 0);
      b_o    : out std_logic_vector(CHANNELS-1 downto 0);
      ack_o  : out std_logic_vector(CHANNELS-1 downto 0));
end entity SyncClockDomains;

architecture Structural of SyncClockDomains is
begin

   make_channels:
   for i in 0 to CHANNELS-1 generate
       SCDB: SyncClockDomainsBase
          generic map(INBYLEVEL => INBYLEVEL, FFSTAGES => FFSTAGES)
          port map(rst_i => rst_i, clkA_i => clkA_i , clkB_i => clkB_i,
                   a_i => a_i(i), b_o => b_o(i), ack_o => ack_o(i));
   end generate make_channels;

end architecture Structural;
