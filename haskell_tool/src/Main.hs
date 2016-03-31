{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TupleSections #-}

module Main where

import Data.Functor ((<$>))
import qualified Data.Map as M
import qualified Data.List as L
import Network.IPTables.Ruleset
import Network.IPTables.Parser
import Network.IPTables.IpassmtParser
import System.Environment (getArgs, getProgName)
import System.IO
import Common.Util (isParseErrorWindowsNewline)
import Network.IPTables.Analysis as Analysis
import qualified Network.IPTables.Generated as Isabelle

putErrStrLn = hPutStrLn stderr

preprocessForSpoofingProtection = Isabelle.upper_closure . Isabelle.ctstate_assume_new

exampleCertSpoof ipassmt fuc = map (\ifce -> (ifce, Isabelle.no_spoofing_iface ifce ipassmtMap fuc)) interfaces
    where interfaces = map fst ipassmt
          ipassmtMap = Isabelle.map_of_ipassmt ipassmt

readIpAssmt filename = do
    src <- readFile filename
    case parseIpAssmt filename src of
        Left err -> do print err
                       error $ "could not parse " ++ filename
        Right res -> do putStrLn "Parsed IpAssmt"
                        putStrLn (show res)
                        return $ ipAssmtToIsabelle res


getIpAssmt = do
    args <- getArgs
    progName <- getProgName
    case length args of
      0 -> do putStrLn "no argument supplied"
              putStrLn "for the sake of example, I'm loading ipassmt_generic"
              putStrLn "Supply the ipassmt to get better results!"
              return Isabelle.ipassmt_generic
              --return Isabelle.example_TUM_i8_spoofing_ipassmt
      1 -> do putStrLn $ "loading ipassmt from `" ++ filename ++ "'"
              readIpAssmt filename
                  where filename = head args
      _ -> do putStrLn $ "Usage: " ++ progName ++ " ipassmt_file"
              error "too many command line parameters"


-- TODO: select table and chain

readArgs = getArgs >>= \case
    "-h" : _ ->
        return Nothing
    "-a" : assignmentFile : rest -> do
        assmt <- readIpAssmt assignmentFile
        input <- readInput rest
        return $ Just (assmt, input)
    ('-' : _) : _ -> error "ERROR: unknown argument, try `-h`"
    rest -> do
        putErrStrLn "WARNING: no IP assignment specified, loading a generic file"
        input <- readInput rest
        return $ Just (Isabelle.ipassmt_generic, input)
    where readInput [] = ("<stdin>",) <$> getContents
          readInput [file] = (file,) <$> readFile file
          readInput rest = error "ERROR: to many files"

usage :: IO ()
usage = do
    name <- getProgName
    putErrStrLn $ "Usage: " ++ name ++ " [-a FILE | -h] [FILE]"
    putErrStrLn "Parse `iptables-save` output from FILE or standard input"
    putErrStrLn ""
    putErrStrLn $ "  -a FILE   optional IP assignment file; if unspecified, a generic file is loaded"
    putErrStrLn $ "  -h        print this help text"


main :: IO ()
main = readArgs >>= \case
    Nothing ->
        usage
    Just (ipassmt, (srcname, src)) ->
        case parseIptablesSave srcname src of
            Left err -> do
                if isParseErrorWindowsNewline err
                then putStrLn "WARNING: File has Windows line endings.\n\
                               \Windows newlines are not supported."
                else return ()
                print err
            Right res -> do
                let verbose = True
                putStrLn $ "== Parser output =="
                putStrLn $ show res
                unfolded <- loadUnfoldedRuleset verbose "filter" "FORWARD" res
                putStrLn "== unfolded FORWARD chain (upper closure) =="
                putStrLn $ L.intercalate "\n" $ map show (Isabelle.upper_closure $ unfolded)
                putStrLn "== to simple firewall =="
                putStrLn $ L.intercalate "\n" $ map show (Analysis.toSimpleFirewall unfolded)
                putStrLn "== to even-simpler firewall =="
                let upper_simple = Analysis.toSimpleFirewallWithoutInterfaces ipassmt unfolded
                putStrLn $ L.intercalate "\n" $ map show upper_simple
                putStrLn "== checking spoofing protection =="
                let fuc = preprocessForSpoofingProtection unfolded --Firewall Under Certification
                --putStrLn $ show fuc
                putStrLn $ "ipassmt_sanity_defined: " ++ show (Isabelle.ipassmt_sanity_defined fuc (Isabelle.map_of_ipassmt ipassmt))
                mapM_ putStrLn (Isabelle.debug_ipassmt ipassmt fuc)
                mapM_  (putStrLn . show) (exampleCertSpoof ipassmt fuc)
                putStrLn "== calculating service matrices =="
                putStrLn "===========SSH========="
                putStrLn $ showServiceMatrix $ Isabelle.access_matrix_pretty Isabelle.parts_connection_ssh upper_simple
                putStrLn "===========HTTP========="
                putStrLn $ showServiceMatrix $ Isabelle.access_matrix_pretty Isabelle.parts_connection_http upper_simple
            where showServiceMatrix (nodes, vertices) = concat (map (\(n, desc) -> n ++ " |-> " ++ desc ++ "\n") nodes) ++ "\n" ++
                                                        concat (map (\v -> show v ++ "\n") vertices)

