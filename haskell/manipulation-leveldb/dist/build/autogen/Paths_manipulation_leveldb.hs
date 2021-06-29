module Paths_manipulation_leveldb (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/orpington/.cabal/bin"
libdir     = "/home/orpington/.cabal/lib/x86_64-linux-ghc-7.10.3/manipulation-leveldb-0.1.0.0-EZTLXFp4MUx66M4XcbFhr5"
datadir    = "/home/orpington/.cabal/share/x86_64-linux-ghc-7.10.3/manipulation-leveldb-0.1.0.0"
libexecdir = "/home/orpington/.cabal/libexec"
sysconfdir = "/home/orpington/.cabal/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "manipulation_leveldb_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "manipulation_leveldb_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "manipulation_leveldb_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "manipulation_leveldb_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "manipulation_leveldb_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
