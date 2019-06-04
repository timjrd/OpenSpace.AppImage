#!/usr/bin/env runhaskell
-- broken-dlopen.hs
-- 
-- Parse strace output to find missing dlopened libraries.
-- 
-- Usage:
--   $ strace -o trace.txt PROGRAM
--   $ runhaskell broken-dlopen.hs < trace.txt

import Data.List
import System.FilePath

main = getContents >>= putStrLn . unlines . report . lines

report input = concatMap f $ broken input
  where f x = [] : x : paths x input

paths x = map ("  "++) . map getPath . filter (allInfixOf ["openat", x])

broken input = notFound input \\ found input

notFound = extract isNotFound
found    = extract isFound

extract f = nub . map takeFileName . map getPath . filter f

isNotFound   = allInfixOf ["openat", ".so", "No such file or directory"]
isFound line = allInfixOf ["openat", ".so"] line
  && not ("No such file or directory" `isInfixOf` line)

allInfixOf infixes line = and $ map (`isInfixOf` line) infixes

getPath = takeWhile (/= '"') . tail . dropWhile (/= '"')
