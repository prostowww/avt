-- request write from scheme to cpu
-- init write request
-- spec 2.2.7
reqaddr_o     <= addr_gl
reqlength_o   <= leng
reqtag        <= "0"
reqiswrite_o  <= "1"
request_o     <= "1"
-- run request
wait(grant_i)
  reqdata_o <= do
  reqwe_o   <= "1"
  if (reqbusy!=1) 
    next do
    reqaddr_o++
-- on end
request_o <= "0"
wait(!grant_i)
-- request ended

-- request read from cpu to scheme
-- init read request
reqaddr_o     <= addr_gl
reqlength_o   <= leng
request_o     <= "1"
reqtag        <= tag
reqiswrite_o  <= "0"
-- run request
wait(grant_i)
  request_o <= "0"
  wait(!grant_i)
-- ready for next
-- wait completition
wait(complwe_i)
  tag <= compltag_i
  di  <= compldata_i
  next di
  
-- reqrep
--! done

-- priorety
-- round
  
-- dmaput - write requests dma controller
-- init dmaput
local_addr_i  <= addr_lc
remote_addr_i <= addr_gl
length_i      <= leng
start_i       <= "1"
-- wait start
wait(!done_i)
  start_i <= "0"
-- wait end
wait(done_i)
-- dmaget - read requests dma controller
-- init gmaget
local_addr_i  <= addr_lc
remote_addr_i <= addr_gl
length_i      <= leng
start_i       <= "1"
-- wait start
wait(!done_i)
  start_i <= "0"
-- wait end
wait(done_i)

-- ramget 
-- ramput - memmory multiplexors

-- window
-- 