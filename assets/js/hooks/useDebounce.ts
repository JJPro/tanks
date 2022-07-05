import { useEffect } from "react";
import { useTimeout } from "./useTimeout";

export function useDebounce(callback, delay: number, dependencies: [any]) {
  const {reset, clear}  = useTimeout(callback, delay)
  useEffect(reset, [...dependencies, reset])
  useEffect(clear, [])
}
